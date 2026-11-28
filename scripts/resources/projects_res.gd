class_name TagItProjectResource
extends Resource


const RESOURCE_LOCATION: String = "user://projects/tag_projects.tres"
const THUMBNAILS_LOCATION: String = "user://projects/thumbnails/"
const RESOURCES_LOCATION: String = "user://projects/resources/"

@export var projects: Array[Dictionary] = []
@export var projects_data: Dictionary[String, Dictionary] = {}


static func build_resource_path(project_hash: String, resource_file: String) -> String:
	var path: String = ProjectSettings.globalize_path(RESOURCES_LOCATION)
	var hash_prefix: String = project_hash.substr(0, 2)
	var fullpath: String = path.path_join(hash_prefix).path_join(project_hash).path_join("attatchments").path_join(resource_file)
	return fullpath


static func get_resources_path(project_hash: String) -> String:
	var path: String = ProjectSettings.globalize_path(RESOURCES_LOCATION)
	var hash_prefix: String = project_hash.substr(0, 2)
	var fullpath: String = path.path_join(hash_prefix).path_join(project_hash).path_join("attatchments/")
	if not fullpath.ends_with("/"):
		fullpath += "/"
	return fullpath


static func get_project_path(project_hash: String) -> String:
	var path: String = ProjectSettings.globalize_path(RESOURCES_LOCATION)
	var hash_prefix: String = project_hash.substr(0, 2)
	var fullpath: String = path.path_join(hash_prefix).path_join(project_hash).path_join("project.tres")
	return fullpath


static func get_project_folder(project_hash: String) -> String:
	var path: String = ProjectSettings.globalize_path(RESOURCES_LOCATION)
	var hash_prefix: String = project_hash.substr(0, 2)
	var fullpath: String = path.path_join(hash_prefix).path_join(project_hash)
	return fullpath


static func get_thumbnails_path() -> String:
	var path: String = ProjectSettings.globalize_path(THUMBNAILS_LOCATION)
	if not path.ends_with("/"):
		path += "/"
	return path


static func build_thumbnail_path(file: String) -> String:
	var path: String = ProjectSettings.globalize_path(THUMBNAILS_LOCATION)
	return path.path_join(file)


static func get_resource_path() -> String:
	return ProjectSettings.globalize_path(RESOURCE_LOCATION)


static func get_projects() -> TagItProjectResource:
	var path: String = get_resource_path()
	if FileAccess.file_exists(path):
		var pre_res: Resource = load(path)
		if pre_res != null and pre_res is TagItProjectResource:
			return pre_res
	return TagItProjectResource.new()


func get_project_ids() -> Array[String]:
	var p_ids: Array[String] = []
	var p_updates: Dictionary[String, int]
	for project_id in projects_data:
		var project: Dictionary = projects_data[project_id]
		var up_time: int = project.get("last_update", 0)
		p_updates[project_id] = up_time
	
	p_ids.assign(p_updates.keys())
	
	p_ids.sort_custom(
			func (a:String,b:String) -> bool:
				return p_updates[b] < p_updates[a])
	
	return p_ids


func create_from_project(project: TagItProject) -> bool:
	if project._uuid.is_empty() or has_project(project._uuid):
		return false
	
	projects_data[project._uuid] = {
		"uid_hash": project._hash,
		"name": project.title,
		"description": project.description}
	
	return true


func set_project_last_update(uuid: String, access: int) -> bool:
	if projects_data.has(uuid):
		projects_data[uuid]["last_update"] = access
		return true
	return false


func has_project(uuid: String) -> bool:
	return projects_data.has(uuid)


func get_project_data(uuid: String) -> TagItProject:
	if not projects_data.has(uuid):
		return null
	
	var p_hash: String = projects_data[uuid].get("uid_hash", "")
	
	if p_hash.is_empty():
		return
	
	var project_path: String = get_project_path(p_hash)
	if not FileAccess.file_exists(project_path):
		return null
	
	var res: Resource = load(project_path)
	if res != null and res is TagItProject:
		res._uuid = uuid
		return res
	else:
		return null


func get_display_card_data(uuid: String) -> Dictionary:
	if not projects_data.has(uuid):
		return {}
	
	var project: Dictionary  = projects_data[uuid]
	var p_name: String = project.get("name", "")
	var p_desc: String = project.get("description", "")
	var p_hash: String = project["uid_hash"]
	var thummb_file: String = p_hash + ".webp"
	var thumb: ImageTexture = null
	var thumb_path: String = build_thumbnail_path(thummb_file)
	if FileAccess.file_exists(thumb_path):
		var img: Image = Image.load_from_file(thumb_path)
		if img != null:
			thumb = ImageTexture.create_from_image(img)
	
	return {"title": p_name, "description": p_desc, "thumbnail": thumb}


func get_new_project_uuid() -> String:
	return UUID.generate_new()


func get_project_image_path(uuid: String) -> String:
	if projects_data.has(uuid):
		var t_hash: String = projects_data[uuid]["uid_hash"]
		return t_hash + ".webp"
	return ""


func get_project_title(uuid: String) -> String:
	return projects_data.get(uuid, DictUtils.EMPTY).get("name", "")


func set_project_title(uuid: String, title: String) -> void:
	if projects_data.has(uuid):
		projects_data[uuid]["name"] = title


func set_project_description(uuid: String, description: String) -> void:
	if projects_data.has(uuid):
		projects_data[uuid]["description"] = description


func get_project_description(uuid: String) -> String:
	return projects_data.get(uuid, DictUtils.EMPTY).get("description", "")


func delete_project(project_uuid: String) -> void:
	if not projects_data.has(project_uuid):
		return
	
	var data: Dictionary = projects_data[project_uuid]
	var p_hash: String = data.get("uid_hash", project_uuid.replace("-", "_"))
	var folder: String = get_project_folder(p_hash)
	
	if DirAccess.dir_exists_absolute(folder):
		OS.move_to_trash(folder)
	
	var thumb: String = build_thumbnail_path(
			data.get("image_path", ""))
	if not thumb.is_empty() and FileAccess.file_exists(thumb):
		OS.move_to_trash(thumb)
	
	projects_data.erase(project_uuid)


func project_exists(project_uuid: String) -> bool:
	return projects_data.has(project_uuid)


func validate_projects() -> void:
	for project_uuid in projects_data.keys():
		var data: Dictionary = projects_data[project_uuid]
		var p_hash: String = data.get("uid_hash", project_uuid.replace("-", ""))
		var p_path: String = get_project_path(p_hash)
		if not FileAccess.file_exists(p_path):
			projects_data.erase(project_uuid)
			continue
	save()


func save() -> void:
	ResourceSaver.save(self, get_resource_path())
