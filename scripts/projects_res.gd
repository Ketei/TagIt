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


func create_project(p_name: String, tags: Array[String], suggestions: Array[String], groups: Array[int], image_path: String, alt_lists: Array[Dictionary]) -> int:
	var project_index: int = projects.size()
	projects.append({
		"name": p_name,
		"tags": tags,
		"suggestions": suggestions,
		"groups": groups,
		"image_path": image_path,
		"alt_lists": alt_lists})
	return project_index


func overwrite_project(project_idx: int,p_name: String, tags: Array[String], suggestions: Array[String], groups: Array[int], image_path: String, alt_lists: Array[Dictionary]) -> void:
	projects[project_idx] = {
		"name": p_name,
		"tags": tags,
		"suggestions": suggestions,
		"groups": groups,
		"image_path": image_path,
		"alt_lists": alt_lists}


func delete_project(project_idx: int) -> void:
	if not projects[project_idx]["image_path"].is_empty():
		var thumbnail_path: String = get_thumbnails_path() + projects[project_idx]["image_path"]
		if FileAccess.file_exists(thumbnail_path):
			OS.move_to_trash(thumbnail_path)
	projects.remove_at(project_idx)


func save() -> void:
	ResourceSaver.save(self, get_resource_path())
