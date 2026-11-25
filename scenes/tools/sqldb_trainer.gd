class_name SQLiteTrainer
extends Node

signal training_progress(current: int, total: int, status_text: String)
signal training_finished(trained_post_count: int, total_vocab_size: int)
signal training_failed(error_message: String)

signal _batch_worker_done
signal _save_worker_done

const TVEC_PATH: String = "user://tag_vectors.tvec"
const LOG_PATH: String = "user://sql_training_log.json"
const BATCH_SIZE: int = 250
const DIMENSIONS: int = 128

var last_trained_id: int = 0
var tag_vectors: Dictionary[String, PackedFloat32Array] = {}

var _is_training: bool = false


func _ready() -> void:
	_load_training_log()


func train(amount: int) -> void:
	if _is_training or amount <= 0:
		return
	
	_is_training = true
	training_progress.emit(0, amount, "Querying database...")
	
	var query: String = "SELECT id, tag_id 
						FROM data 
						WHERE id >= %d 
						ORDER BY id ASC
						LIMIT %d;" % [last_trained_id, amount]
	SingletonManager.TagIt.tag_database.query(query)
	var response: Array[Dictionary] = SingletonManager.TagIt.tag_database.query_result
	if response.is_empty():
		# Added: Reset lock before returning
		_is_training = false
		training_failed.emit("No entries returned from DB.")
		return
	
	var ids: Array[int] = []
	var next_start_id: int = last_trained_id
	for item: Dictionary in response:
		ids.append(int(item["tag_id"]))
		# Added: Track highest row ID so next run continues where this stopped
		var row_id: int = int(item["id"])
		if row_id >= next_start_id:
			next_start_id = row_id + 1
	
	# Changed: Fetch SQLite rows on main thread to avoid SQLite thread-safety crashes
	var suggestions: Dictionary[String, Array] = _fetch_tag_suggestions(ids)
	
	if suggestions.is_empty():
		_is_training = false
		training_failed.emit("No suggestions to train on found.")
		return
	
	var task_id: int = WorkerThreadPool.add_task(_train_suggestions_worker.bind(suggestions))
	await _batch_worker_done
	WorkerThreadPool.wait_for_task_completion(task_id)
	
	last_trained_id = next_start_id
	
	training_progress.emit(suggestions.size(), suggestions.size(), "Normalizing and saving .tvec...")
	var save_task: int = WorkerThreadPool.add_task(_finalize_and_save_worker)
	await _save_worker_done
	WorkerThreadPool.wait_for_task_completion(save_task)
	
	_is_training = false
	training_finished.emit(suggestions.size(), tag_vectors.size())


func _fetch_tag_suggestions(tag_ids: Array[int]) -> Dictionary[String, Array]:
	var suggestion_data: Dictionary[String, Array] = {}
	var job_count: int = tag_ids.size()
	var current_job: int = 0
	var suggestion_ids: Dictionary[int, String] = {}
	
	for tag: int in tag_ids:
		current_job += 1
		
		var data: Array = SingletonManager.TagIt.tag_database.select_rows(
				"tags",
				"id = %d" % tag,
				["name"])
		
		if data.is_empty():
			continue
		
		var column: Dictionary = data[0]
		if not column.has("name") or typeof(column["name"]) != TYPE_STRING:
			continue
		
		# Changed: Normalize case/whitespace to match HydrusTrainer keys
		var tag_name: String = str(column["name"]).strip_edges().to_lower()
		if tag_name.is_empty():
			continue
		
		var suggs: Array = SingletonManager.TagIt.tag_database.select_rows(
				"suggestions",
				"tag_id = %d" % tag,
				["suggestion_id"])
		
		var string_suggestions: Array[String] = []
		var query_suggestions: Array[int] = []
		
		for suggestion_row: Dictionary in suggs:
			var sugg_data: Variant = suggestion_row.get("suggestion_id")
			if typeof(sugg_data) == TYPE_INT:
				var int_sugg: int = int(sugg_data)
				if suggestion_ids.has(int_sugg):
					string_suggestions.append(suggestion_ids[int_sugg])
				else:
					query_suggestions.append(int_sugg)
		
		if not query_suggestions.is_empty():
			# Changed: JSON.stringify(...).trim_prefix("[").trim_suffix("]") safely formats int arrays
			var id_str: String = JSON.stringify(query_suggestions).trim_prefix("[").trim_suffix("]")
			var rows: Array = SingletonManager.TagIt.tag_database.select_rows(
					"tags",
					"id IN (%s)" % id_str,
					["id", "name"])
				
			for row: Dictionary in rows:
				var name_data: Variant = row.get("name")
				if typeof(name_data) == TYPE_STRING:
					var clean_sugg: String = str(name_data).strip_edges().to_lower()
					if not clean_sugg.is_empty():
						string_suggestions.append(clean_sugg)
						suggestion_ids[int(row["id"])] = clean_sugg
		
		# Added: Skip tags with zero suggestions so empty entries don't pollute training counts
		if not string_suggestions.is_empty():
			suggestion_data[tag_name] = string_suggestions
		
		if current_job % 25 == 0:
			training_progress.emit(current_job, job_count, "Fetching DB suggestions...")
	
	return suggestion_data


func _train_suggestions_worker(suggestion_data: Dictionary[String, Array]) -> void:
	var anchor_tags: Array = suggestion_data.keys()
	var total_anchors: int = anchor_tags.size()
	
	# Ensure every anchor and suggested tag has a vector initialized
	for anchor: String in anchor_tags:
		if not tag_vectors.has(anchor):
			tag_vectors[anchor] = _create_random_vector()
		var related_list: Array = suggestion_data[anchor]
		for related: String in related_list:
			if not tag_vectors.has(related):
				tag_vectors[related] = _create_random_vector()
	
	var vocab_keys: Array = tag_vectors.keys()
	var vocab_size: int = vocab_keys.size()
	var epochs: int = 3
	
	for epoch: int in range(epochs):
		var lr: float = lerpf(0.08, 0.02, float(epoch) / float(epochs))
		for i: int in range(total_anchors):
			var anchor: String = str(anchor_tags[i])
			var related_list: Array = suggestion_data[anchor]
			var vec_anchor: PackedFloat32Array = tag_vectors[anchor]
			
			# Pull anchor directly toward each explicitly suggested tag
			for related: String in related_list:
				var vec_rel: PackedFloat32Array = tag_vectors[related]
				_apply_pair_update(vec_anchor, vec_rel, 1.0, lr)
				
				# Push anchor away from 2 unrelated tags
				if vocab_size > 10:
					for n: int in range(2):
						var rand_tag: String = str(vocab_keys[randi() % vocab_size])
						if rand_tag != anchor and not related_list.has(rand_tag):
							var vec_neg: PackedFloat32Array = tag_vectors[rand_tag]
							_apply_pair_update(vec_anchor, vec_neg, 0.0, lr * 0.5)
			
			if i % 25 == 0:
				var step: int = (epoch * total_anchors) + i
				var total_steps: int = epochs * total_anchors
				training_progress.emit.call_deferred(step, total_steps, "Training DB relations (Pass %d/%d)..." % [epoch + 1, epochs])
	
	_batch_worker_done.emit.call_deferred()


func _finalize_and_save_worker() -> void:
	_normalize_all_vectors()
	save_tvec_to_user()
	_save_training_log()
	
	_save_worker_done.emit.call_deferred()


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
	if typeof(parsed) == TYPE_DICTIONARY:
		if parsed.has("id"):
			last_trained_id = int(parsed["id"])


func _save_training_log() -> void:
	var file := FileAccess.open(LOG_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify({"id": last_trained_id}))
		file.close()
