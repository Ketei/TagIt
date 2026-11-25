class_name HydrusTrainer
extends Node

signal training_progress(current: int, total: int, status_text: String)
signal training_finished(trained_post_count: int, total_vocab_size: int)
signal training_failed(error_message: String)

signal _batch_worker_done
signal _save_worker_done

const TVEC_PATH: String = "user://tag_vectors.tvec"
const LOG_PATH: String = "user://hydrus_training_log.json"
const DIMENSIONS: int = 128
const BATCH_SIZE: int = 250

const LOCAL_ADDRESS: String = "http://127.0.0.1:%d/"
const META_ENDPOINT: String = "get_files/file_metadata?file_ids=%s"
const HEADER: String = "Hydrus-Client-API-Access-Key:"
const SEARCH: String = "get_files/search_files?tags="

@export var ignored_namespaces: Array[String] = ["creator:", "meta:", "series:", "page:", "rating:"]
var namespaces_to_sanitize: Array[String] = ["character:", "species:"]
var prefixes_to_exclude: Array[String] = []
var tags_to_ignore: Dictionary[String, Variant] = {}

var hydrus_access: String = ""
var tag_vectors: Dictionary[String, PackedFloat32Array] = {}
var trained_ids: Dictionary[int, Variant] = {}
var _http: HTTPRequest

var _is_training: bool = false


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_load_training_log()


func get_hydrus_headers(key: String = SingletonManager.TagIt.settings.hydrus_key) -> PackedStringArray:
	return PackedStringArray([HEADER + key])


func _on_hydrus_data_set(data: String) -> void:
	hydrus_access = data


func train_from_hydrus(search_tags: Array[String], max_posts: int, ignore_tags: Array[String] = [], exclude_prefixes: Array[String] = [], ignore_training_log: bool = false) -> void:
	if _is_training:
		return
	
	if search_tags.is_empty() or max_posts <= 0:
		training_finished.emit(0, tag_vectors.size())
		return
	
	prefixes_to_exclude.assign(exclude_prefixes)
	prefixes_to_exclude.append_array(ignored_namespaces)
	tags_to_ignore.clear()
	_is_training = true
	
	var ip_address: String = LOCAL_ADDRESS % SingletonManager.TagIt.settings.hydrus_port
	var endpoint: String = ip_address.path_join(SEARCH)
	var url: String = endpoint
	
	var all_tags: Array[String] = ["system:archive"]
	
	if not search_tags.is_empty():
		all_tags.append_array(search_tags)
	if not ignore_tags.is_empty():
		for tag in ignore_tags:
			tags_to_ignore[tag] = null
	
	var full_tags: String = JSON.stringify(all_tags)
	var uri_tags: String = full_tags.uri_encode()
	url += uri_tags
	
	training_progress.emit(0, max_posts, "Searching Hydrus files...")
	
	var file_ids: Array[int] = await _fetch_matching_file_ids(url)
	
	if file_ids.is_empty():
		_is_training = false
		training_failed.emit("No files returned from Hydrus.")
		return
	
	var target_ids: Array[int] = []
	for id: int in file_ids:
		if not ignore_training_log and trained_ids.has(id):
			continue
		target_ids.append(id)
		if max_posts <= target_ids.size():
			break
	
	if target_ids.is_empty():
		_is_training = false
		training_finished.emit(0, tag_vectors.size())
		return
	
	var total_targets: int = target_ids.size()
	var processed: int = 0
	
	for offset: int in range(0, total_targets, BATCH_SIZE):
		var end_idx: int = mini(offset + BATCH_SIZE, total_targets)
		var chunk: Array[int] = target_ids.slice(offset, end_idx)
		
		training_progress.emit(processed, total_targets, "Fetching metadata batch...")
		var post_tag_lists: Array[Array] = await _fetch_metadata_batch(chunk)
		
		var task_id: int = WorkerThreadPool.add_task(_process_batch_worker.bind(post_tag_lists, processed, total_targets))
		await _batch_worker_done
		WorkerThreadPool.wait_for_task_completion(task_id)
		
		for id: int in chunk:
			trained_ids[id] = null
		
		processed += chunk.size()
		training_progress.emit(processed, total_targets, "Trained %d / %d posts" % [processed, total_targets])
	
	training_progress.emit(total_targets, total_targets, "Normalizing and saving .tvec...")
	var save_task: int = WorkerThreadPool.add_task(_finalize_and_save_worker)
	await _save_worker_done
	WorkerThreadPool.wait_for_task_completion(save_task)
	
	_is_training = false
	
	training_finished.emit(processed, tag_vectors.size())


func _process_batch_worker(post_tag_lists: Array[Array], base_count: int, total_targets: int) -> void:
	_sanitize_tags(post_tag_lists)
	for i: int in post_tag_lists.size():
		_train_on_single_post(post_tag_lists[i], 0.03)
		if i % 25 == 0:
			training_progress.emit.call_deferred(base_count + i, total_targets, "Training vectors...")
	
	_batch_worker_done.emit.call_deferred()


func _finalize_and_save_worker() -> void:
	_normalize_all_vectors()
	save_tvec_to_user()
	_save_training_log()
	
	_save_worker_done.emit.call_deferred()


func _sanitize_tags(tag_lists: Array[Array]) -> void:
	for arr: Array in tag_lists:
		for idx: int in arr.size():
			var tag: String = arr[idx]
			if not tag.contains(":"):
				continue
			for pre: String in namespaces_to_sanitize:
				if tag.begins_with(pre):
					arr[idx] = tag.trim_prefix(pre)
					break


func _fetch_matching_file_ids(url: String) -> Array[int]:
	var err: Error = _http.request(url, get_hydrus_headers())
	if err != OK:
		return []
	
	var response: Array = await _http.request_completed
	if int(response[1]) != 200:
		return []
	
	var json_data: Variant = JSON.parse_string((response[3] as PackedByteArray).get_string_from_utf8())
	var result: Array[int] = []
	if json_data is Dictionary and json_data.has("file_ids"):
		result.assign(json_data["file_ids"])
	return result


func _fetch_metadata_batch(file_ids: Array[int]) -> Array[Array]:
	var ids_strings: String = JSON.stringify(file_ids)
	var encoded_ids: String = ids_strings.uri_encode()
	var ip_address: String = LOCAL_ADDRESS % SingletonManager.TagIt.settings.hydrus_port
	var endpoint: String = META_ENDPOINT % encoded_ids
	var url: String = ip_address.path_join(endpoint)
	
	var err: Error = _http.request(url, get_hydrus_headers())
	if err != OK:
		return []
	
	var response: Array = await _http.request_completed
	if int(response[1]) != 200:
		return []
	
	var json_data: Variant = JSON.parse_string((response[3] as PackedByteArray).get_string_from_utf8())
	var all_posts: Array[Array] = []
	if not (json_data is Dictionary and json_data.has("metadata")):
		return all_posts
	
	for entry: Variant in json_data["metadata"]:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var clean_tags: Array[String] = _extract_clean_tags(entry)
		if clean_tags.size() >= 2:
			all_posts.append(clean_tags)
	
	return all_posts


func _extract_clean_tags(metadata_entry: Dictionary) -> Array[String]:
	var unique_tags: Dictionary[String, Variant] = {}
	var services: Variant = metadata_entry.get("tags")
	if typeof(services) == TYPE_DICTIONARY:
		for service_key: Variant in services:
			var service_data: Variant = services[service_key]
			if typeof(service_data) != TYPE_DICTIONARY:
				continue
			var display_tags: Variant = service_data.get("display_tags")
			if typeof(display_tags) != TYPE_DICTIONARY:
				continue
			var current_tags: Variant = display_tags.get("0")
			if typeof(current_tags) == TYPE_ARRAY:
				for raw_tag: Variant in current_tags:
					var tag_str: String = str(raw_tag).strip_edges().to_lower()
					if _is_valid_tag(tag_str):
						unique_tags[tag_str] = null
	
	var output: Array[String] = []
	if not unique_tags.is_empty():
		output.assign(unique_tags.keys())
	
	return output


func _is_valid_tag(tag_str: String) -> bool:
	if tag_str.is_empty() or tags_to_ignore.has(tag_str):
		return false
	for prefix: String in prefixes_to_exclude:
		if tag_str.begins_with(prefix):
			return false
	return true


func _train_on_single_post(post_tags: Array[String], learning_rate: float) -> void:
	for tag: String in post_tags:
		if not tag_vectors.has(tag):
			tag_vectors[tag] = _create_random_vector()
	
	var vocab_keys: Array = tag_vectors.keys()
	var vocab_size: int = vocab_keys.size()
	
	for i: int in post_tags.size():
		var vec_a: PackedFloat32Array = tag_vectors[post_tags[i]]
		for j: int in range(i + 1, post_tags.size()):
			var vec_b: PackedFloat32Array = tag_vectors[post_tags[j]]
			_apply_pair_update(vec_a, vec_b, 1.0, learning_rate)
		
		if vocab_size > 10:
			for n: int in range(3):
				var rand_tag: String = str(vocab_keys[randi() % vocab_size])
				if not post_tags.has(rand_tag):
					var vec_neg: PackedFloat32Array = tag_vectors[rand_tag]
					_apply_pair_update(vec_a, vec_neg, 0.0, learning_rate * 0.5)


func _apply_pair_update(vec_a: PackedFloat32Array, vec_b: PackedFloat32Array, target: float, lr: float) -> void:
	var dot: float = 0.0
	for d: int in DIMENSIONS:
		dot += vec_a[d] * vec_b[d]
	
	var prediction: float = 1.0 / (1.0 + exp(-clampf(dot, -10.0, 10.0)))
	var grad: float = lr * (target - prediction)
	
	for d: int in DIMENSIONS:
		var a_val: float = vec_a[d]
		var b_val: float = vec_b[d]
		vec_a[d] = a_val + grad * b_val
		vec_b[d] = b_val + grad * a_val


func _create_random_vector() -> PackedFloat32Array:
	var vec := PackedFloat32Array()
	vec.resize(DIMENSIONS)
	for d: int in DIMENSIONS:
		vec[d] = randf_range(-0.05, 0.05)
	return vec


func _normalize_all_vectors() -> void:
	for tag: String in tag_vectors:
		var vec: PackedFloat32Array = tag_vectors[tag]
		var mag_sq: float = 0.0
		for d: int in range(DIMENSIONS):
			mag_sq += vec[d] * vec[d]
		if mag_sq > 0.000001:
			var inv_mag: float = 1.0 / sqrt(mag_sq)
			for d: int in DIMENSIONS:
				vec[d] *= inv_mag


func save_tvec_to_user(path: String = TVEC_PATH) -> Error:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	
	var keys: Array = tag_vectors.keys()
	keys.sort()
	
	file.store_buffer("TVEC".to_ascii_buffer())
	file.store_32(1)
	file.store_32(DIMENSIONS)
	file.store_32(keys.size())
	
	for tag: String in keys:
		var utf8: PackedByteArray = tag.to_utf8_buffer()
		file.store_16(utf8.size())
		file.store_buffer(utf8)
	
	for tag: String in keys:
		var vec: PackedFloat32Array = tag_vectors[tag]
		file.store_buffer(vec.to_byte_array())
	
	file.close()
	return OK


func _load_training_log() -> void:
	if not FileAccess.file_exists(LOG_PATH):
		return
	var text: String = FileAccess.get_file_as_string(LOG_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) == TYPE_ARRAY:
		for id: Variant in parsed:
			var int_id: int = int(id)
			trained_ids[int_id] = null


func _save_training_log() -> void:
	if trained_ids.is_empty():
		return
	var ids: Array[int] = []
	ids.assign(trained_ids.keys())
	
	var file := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(ids))
		file.close()
