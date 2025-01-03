class_name TemplateResource
extends Resource

const TEMPLATE_PATH: String = "user://templates/templates.tres"
const TEMPLATE_THUMBNAILS: String = "user://templates/thumbnails/"
@export var templates: Array[Dictionary] = []


static func get_thumbnail_path() -> String:
	var path: String = ProjectSettings.globalize_path(TEMPLATE_THUMBNAILS)
	if not path.ends_with("/"):
		path += "/"
	return path


static func get_file_path() -> String:
	var path: String = ProjectSettings.globalize_path(TEMPLATE_PATH)
	return path


static func get_templates() -> TemplateResource:
	var global_path: String = get_file_path()
	if FileAccess.file_exists(global_path):
		var template_res: Resource = load(global_path)
		if template_res != null and template_res is TemplateResource:
			return template_res
	return TemplateResource.new()


func new_template(title: String, description: String, tags: Array[String], groups: Array[int], thumbnail: String) -> void:
	templates.append({
		"title": title,
		"description": description,
		"groups": groups,
		"tags": tags,
		"thumbnail": thumbnail})


func overwrite_template(template_idx: int, title: String, description: String, tags: Array[String], groups: Array[int], thumbnail: String) -> void:
	templates[template_idx] = {
		"title": title,
		"description": description,
		"groups": groups,
		"tags": tags,
		"thumbnail": thumbnail}


func erase_template(template_idx: int) -> void:
	templates.remove_at(template_idx)


func delete_template_thumbnail(template_idx: int) -> void:
	if not templates[template_idx]["thumbnail"].is_empty() and FileAccess.file_exists(get_thumbnail_path() + templates[template_idx]["thumbnail"]):
		OS.move_to_trash(get_thumbnail_path() + templates[template_idx]["thumbnail"])

func get_template(template_idx: int) -> Dictionary:
	return templates[template_idx].duplicate()


func save() -> void:
	ResourceSaver.save(self, get_file_path())
