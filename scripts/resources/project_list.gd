class_name ProjectList
extends Resource


@export_storage var _tags: Dictionary[String, int] = {}
var _tag_id: Dictionary[int, String] = {} # Acts as cache
@export_storage var _taglist: Array[int] = []
@export_storage var _suggestions: Array[int] = []
@export_storage var _groups: Dictionary[int, Dictionary] = {
	#0: {"title": "My Group", "tags": []}
}

@export_storage var _id_counter: int = 0
@export_storage var _project_append: String = ""

var _project_hash: String = ""

@export_storage var index: int = 0


static func hash_file_bytes(file_path: String) -> String:
	var file := FileAccess.open(file_path, FileAccess.READ)
	
	if file == null or file.get_length() == 0:
		return ""

	var hashing_context := HashingContext.new()
	hashing_context.start(HashingContext.HASH_SHA256)

	var chunk_size: int = 65536
	while file.get_position() < file.get_length():
		var remaining_bytes: int = file.get_length() - file.get_position()
		var bytes_to_read: int = mini(chunk_size, remaining_bytes)
		var chunk: PackedByteArray = file.get_buffer(bytes_to_read)
		hashing_context.update(chunk)

	var digest: PackedByteArray = hashing_context.finish()
	return digest.hex_encode().substr(0, 32)


static func save_image_as_hashed_webp(image: Image, output_dir: String, lossy: bool = false, quality: float = 0.75) -> String:
	var webp_buffer: PackedByteArray = image.save_webp_to_buffer(lossy, quality)
	if webp_buffer.is_empty():
		return ""

	var hashing_context := HashingContext.new()
	hashing_context.start(HashingContext.HASH_SHA256)
	hashing_context.update(webp_buffer)
	var digest: PackedByteArray = hashing_context.finish()

	var filename: String = digest.hex_encode().substr(0, 32) + ".webp"
	var full_path: String = output_dir.path_join(filename)

	# Skip writing if an identical file already exists
	if not FileAccess.file_exists(full_path):
		var file := FileAccess.open(full_path, FileAccess.WRITE)
		if file == null:
			return ""
		file.store_buffer(webp_buffer)

	return filename


func append_type() -> String:
	if _project_append.is_empty():
		return ""
	match _project_append.get_extension():
		"gif":
			return "gif"
		_:
			return "img"


func has_append() -> bool:
	return not _project_append.is_empty()


func add_tag_to_list(tag: String) -> void:
	if _tags.has(tag):
		_taglist.append(_tags[tag])
	else:
		var id: int = _claim_id()
		_tags[tag] = id
		_taglist.append(id)
	
	if not _tag_id.is_empty():
		_tag_id.clear()


func add_tag_to_suggestions(tag: String) -> void:
	if _tags.has(tag):
		_suggestions.append(_tags[tag])
	else:
		var id: int = _claim_id()
		_tags[tag] = id
		_suggestions.append(id)


func add_group_suggestions(group_id: int, group_title: String, tags: Array[String]) -> void:
	if not _groups.has(group_id):
		_groups[group_id] = {
			"title": "",
			"tags": Arrays.create_typed(TYPE_STRING)}
	
	var group: Dictionary = _groups[group_id]
	var tag_array: Array = group["tags"]
	
	group["title"] = group_title
	if tags.is_empty():
		return
	
	Arrays.append_uniques(tag_array, tags)


# Saves a loaded static image. Only the resource is needed.
# Image is converted to webP to save space
func save_list_image(data: Image) -> bool:
	if _project_append.is_empty() and data == null:
		return true
	
	if not _project_append.is_empty():
		var path: String = TagItProjectResource.build_resource_path(
				_project_hash,
				_project_append)
		if FileAccess.file_exists(path):
			OS.move_to_trash(path)
		_project_append = ""
	
	if data == null:
		return true
	
	var folder: String = TagItProjectResource.get_resources_path(_project_hash)
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_recursive_absolute(folder)
	var filename: String = save_image_as_hashed_webp(data, folder)
	if filename.is_empty():
		return false
	_project_append = filename
	return true


# Entire resource is moved.
func append_animation(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return false
	
	var extension: String = path.get_extension()
	if not DataManager.is_valid_append_format(extension):
		return false
	
	var file_hash: String = hash_file_bytes(path)
	var file_name: String = file_hash + "." + extension
	var full_path: String = TagItProjectResource.build_resource_path(
			_project_hash,
			file_name)
	
	if not DirAccess.dir_exists_absolute(full_path):
		DirAccess.make_dir_recursive_absolute(full_path)
	
	var error: Error = DirAccess.copy_absolute(path, full_path)
	
	if error == OK:
		_project_append = file_name
		return true
	else:
		return false


func get_project_image_path() -> String:
	if _project_append.is_empty():
		return ""
	var path: String = TagItProjectResource.build_resource_path(
			_project_hash,
			_project_append)
	return path


func get_project_image() -> Resource:
	if _project_append.is_empty() or not _project_append.is_valid_filename():
		return null
	
	var extension: String = _project_append.get_extension()
	
	if not DataManager.is_valid_append_format(extension):
		return null
	
	var path: String = TagItProjectResource.build_resource_path(
			_project_hash,
			_project_append)
	
	if not FileAccess.file_exists(path):
		return null
	
	match extension:
		"gif":
			var res: SpriteFrames = GifManager.sprite_frames_from_file(path)
			return res
		_:
			var img: Image = Image.load_from_file(path)
			if img == null:
				return null
			var tex: ImageTexture = ImageTexture.create_from_image(img)
			if tex == null:
				return null
			else:
				return tex


func get_list_tags() -> Array[String]:
	if _tag_id.is_empty():
		_rebuild_tag_ids()
	
	var tags: Array[String] = []
	
	for tag_id in _taglist:
		var tag_text: String = _tag_id.get(tag_id, "")
		if tag_text.is_empty():
			continue
		tags.append(tag_text)
	
	return tags


func get_suggestion_list() -> Array[String]:
	if _tag_id.is_empty():
		_rebuild_tag_ids()
	
	var tags: Array[String] = []
	for id in _suggestions:
		var text: String = _tag_id.get(id, "")
		if text.is_empty():
			continue
		tags.append(text)
	return tags


func get_groups() -> Dictionary[int, Dictionary]:
	return _groups.duplicate(true)


func clear_tags() -> void:
	_tags.clear()
	_tag_id.clear()
	_taglist.clear()
	_suggestions.clear()
	_groups.clear()
	_id_counter = 0


func _rebuild_tag_ids() -> void:
	if not _tag_id.is_empty():
		_tag_id.clear()
	for tag in _tags:
		_tag_id[_tags[tag]] = tag


func _claim_id() -> int:
	var id: int = _id_counter
	_id_counter += 1
	return id
