class_name TagItProjectResource
extends Resource


const RESOURCE_LOCATION: String = "user://projects/tag_projects.tres"
const THUMBNAILS_LOCATION: String = "user://projects/thumbnails/"

@export var projects: Array[Dictionary] = []


static func get_thumbnails_path() -> String:
	var path: String = ProjectSettings.globalize_path(THUMBNAILS_LOCATION)
	if not path.ends_with("/"):
		path += "/"
	return path


static func get_resource_path() -> String:
	return ProjectSettings.globalize_path(RESOURCE_LOCATION)


static func get_projects() -> TagItProjectResource:
	var path: String = get_resource_path()
	if FileAccess.file_exists(path):
		var pre_res: Resource = load(path)
		if pre_res != null and pre_res is TagItProjectResource:
			return pre_res
	return TagItProjectResource.new()


func create_project(p_name: String, tags: Array[String], suggestions: Array[String], groups: Array[int], image_path: String, alt_lists: Array[Dictionary], custom_priorities: Dictionary, blacklist: PackedStringArray, group_blacklist: PackedInt64Array) -> String:
	var project_uuid: String = get_new_project_uuid()
	projects.append({
		"_uuid": project_uuid,
		"name": p_name,
		"tags": tags,
		"suggestions": suggestions,
		"groups": groups,
		"image_path": image_path,
		"alt_lists": alt_lists,
		"custom_priorities": custom_priorities,
		"blacklist_tags": blacklist,
		"blacklist_groups": group_blacklist})
	return project_uuid


func get_project_data(uuid: String) -> Dictionary:
	for project in projects:
		if project["_uuid"] == uuid:
			return project
	return {}


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
	var uuid: String = Strings.random_string64()

	while is_uuid_used(uuid):
		uuid = Strings.random_string64()
	
	return uuid


func get_project_image_path(uuid: String) -> String:
	for project in projects:
		if project["_uuid"] == uuid:
			return project["image_path"]
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


func save() -> void:
	ResourceSaver.save(self, get_resource_path())
