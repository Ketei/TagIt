class_name TagItProject
extends Resource


@export var _uuid: String = "":
	set(u):
		_uuid = u
		_hash = u.replace("-", "")
@export var _hash: String = "":
	set(h):
		_hash = h
		if shared_list != null:
			shared_list._project_hash = h
		for list in lists:
			lists[list]._project_hash = h

@export var title: String = ""
@export var description: String = ""
@export var custom_priorities: Dictionary[String, int] = {}
@export var tag_blacklist: Array[String] = []
@export var group_blacklist: Array[int] = []
@export var shared_list: ProjectList

@export var lists: Dictionary[String, ProjectList] = {}


func _init() -> void:
	shared_list = ProjectList.new()


func new_list(list_id: String) -> ProjectList:
	if lists.has(list_id):
		return null
	
	var new_l: ProjectList = ProjectList.new()
	new_l._project_hash = _hash
	lists[list_id] = new_l
	return new_l


func set_project_thumbnail(img: Image, lossy: bool = false, quality: float = 0.75) -> bool:
	if _hash.is_empty():
		return false
	
	var thumb_path: String = TagItProjectResource.build_thumbnail_path(
			_hash + ".webp")
	
	if img == null:
		if FileAccess.file_exists(thumb_path):
			OS.move_to_trash(thumb_path)
		return true
	
	var folder: String = thumb_path.get_base_dir()
	
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_recursive_absolute(folder)
		
	var thumb: Image = img.duplicate()
	DataManager.resize_image_to_constraints(thumb)
	var error: int = thumb.save_webp(thumb_path, lossy, quality)
	
	return error == OK


func get_project_thumbnail() -> ImageTexture:
	if _hash.is_empty():
		return null
	
	var thumb_path: String = TagItProjectResource.build_thumbnail_path(
			_hash + ".webp")
	
	if not FileAccess.file_exists(thumb_path):
		return null
	
	var img: Image = Image.load_from_file(thumb_path)
	if img == null:
		return null
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	
	return tex


func get_project_lists() -> Array[String]:
	var ids: Array[String] = []
	if lists.is_empty():
		return ids
	
	ids.assign(lists.keys())
	ids.sort_custom(
			func(a,b) -> bool:
				return lists[a]._index < lists[b]._index)
	return ids


func get_list(list_id: String) -> ProjectList:
	var list: ProjectList = lists.get(list_id)
	if list == null:
		return null
	list._project_hash = _hash
	
	return list


func get_project_image(list: String) -> Resource:
	var p_list: ProjectList = shared_list if list.is_empty() else lists.get(list)
	if p_list == null:
		return null
	
	var file: String = p_list.image_file
	if file.is_empty() or not file.is_valid_filename():
		return null
	
	var formats: Array[String] = DataManager.get_valid_append_formats()
	var extension: String = file.get_extension()
	if not formats.has(extension):
		return null
	
	var path: String = TagItProjectResource.build_resource_path(
			_hash,
			p_list.image_file)
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


func erase_list(list: String) -> void:
	if not lists.has(list):
		return
	
	var target: ProjectList = lists[list]
	var img_path: String = target.get_project_image_path()
	var other_uses: bool = false
	
	if not img_path.is_empty() and FileAccess.file_exists(img_path):
		for o in lists:
			var c: ProjectList = lists[o]
			var path: String = c.get_project_image_path()
			if img_path == path:
				other_uses = true
				break
		
		if not other_uses:
			OS.move_to_trash(img_path)
	
	lists.erase(list)


func clear() -> void:
	custom_priorities.clear()
	tag_blacklist.clear()
	group_blacklist.clear()
	shared_list.clear()
	lists.clear()


func save() -> bool:
	if _uuid.is_empty():
		return false
	var path: String = TagItProjectResource.get_project_path(_hash)
	var folder: String = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_recursive_absolute(folder)
	return ResourceSaver.save(self, path) == OK
