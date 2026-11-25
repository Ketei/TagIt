class_name TagItProjectResource
extends Resource


const RESOURCE_LOCATION: String = "user://projects/tag_projects.tres"
const THUMBNAILS_LOCATION: String = "user://projects/thumbnails/"
const RESOURCES_LOCATION: String = "user://projects/resources/"

@export var projects: Array[Dictionary] = []


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


func create_project(p_name: String) -> String:
	var project_uuid: String = get_new_project_uuid()
	projects.append({
		"_uuid": project_uuid,
		"uid_hash": project_uuid.replace("-", ""),
		"name": p_name})
	return project_uuid


func get_project_ids() -> Array[String]:
	var p_ids: Array[String] = []
	for project in projects:
		p_ids.append(project["_uuid"])
	return p_ids


func create_from_project(project: TagItProject) -> bool:
	if project._uuid.is_empty() or has_project(project._uuid):
		return false
	
	projects.append({
		"_uuid": project._uuid,
		"uid_hash": project._hash,
		"name": project.title})
	
	return true


func has_project(uuid: String) -> bool:
	for project in projects:
		if project["_uuid"] == uuid:
			return true
	return false


func get_project_data(uuid: String) -> TagItProject:
	var p_hash: String = ""
	for project in projects:
		if project["_uuid"] == uuid:
			p_hash = project["uid_hash"]
			break
	
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


func get_project_suggestions(uuid: String) -> Array[String]:
	for project in projects:
		if project["_uuid"] == uuid:
			return project["suggestions"]
	return Array([], TYPE_STRING, &"", null)


func get_project_tags(uuid: String) -> Array[String]:
	for project in projects:
		if project["_uuid"] == uuid:
			return project["tags"]
	return Array([], TYPE_STRING, &"", null)


func overwrite_project(project_uuid: String, p_name: String, tags: Array[String], suggestions: Array[String], groups: Array[int], image_path: String, alt_lists: Array[Dictionary], custom_priorities: Dictionary, suggestion_blacklist: PackedStringArray, group_blacklist: PackedInt64Array) -> void:
	for project in projects:
		if not project["_uuid"] == project_uuid:
			continue
		project["name"] = p_name
		project["tags"] = tags
		project["suggestions"] = suggestions
		project["groups"] = groups
		project["image_path"] = image_path
		project["alt_lists"] = alt_lists
		project["custom_priorities"] = custom_priorities
		project["blacklist_tags"] = suggestion_blacklist
		project["blacklist_groups"] = group_blacklist
		break


func get_new_project_uuid() -> String:
	return UUID.generate_new()


func get_project_image_path(uuid: String) -> String:
	for project in projects:
		if project["_uuid"] == uuid:
			var t_hash: String = project["uid_hash"]
			return t_hash + ".webp"
	return ""


func get_project_title(uuid: String) -> String:
	for project in projects:
		if project["_uuid"] == uuid:
			return project["name"]
	return ""


func is_uuid_used(uuid: String) -> bool:
	for project in projects:
		if project.has("_uuid") and project["_uuid"] == uuid:
			return true
	return false


func delete_project(project_uuid: String) -> void:
	for project_idx in range(projects.size()):
		if projects[project_idx]["_uuid"] != project_uuid:
			continue
		if not projects[project_idx]["image_path"].is_empty():
			var thumbnail_path: String = get_thumbnails_path() + projects[project_idx]["image_path"]
			if FileAccess.file_exists(thumbnail_path):
				OS.move_to_trash(thumbnail_path)
		projects.remove_at(project_idx)
		break


func project_exists(project_uuid: String) -> bool:
	for project in projects:
		if project.get("_uuid") == project_uuid:
			return true
	return false


func save() -> void:
	ResourceSaver.save(self, get_resource_path())
