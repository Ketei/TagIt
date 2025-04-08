class_name TemplateResource
extends Resource


const TEMPLATE_PATH: String = "user://templates/templates.tres"
const TEMPLATE_THUMBNAILS: String = "user://templates/thumbnails/"
@export var templates: Array[Dictionary] = []
var template_stash: Dictionary = {}


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


func new_template(title: String, description: String, tags: Array[String], groups: Array[int], thumbnail: String) -> String:
	var uuid: String = get_new_template_uuid()
	templates.append({
		"_uuid": uuid,
		"title": title,
		"description": description,
		"groups": groups,
		"tags": tags,
		"thumbnail": thumbnail})
	return uuid


func get_new_template_uuid() -> String:
	var uuid: String = Strings.random_string64()
	while has_uuid(uuid):
		uuid = Strings.random_string64()
	return uuid


func has_uuid(uuid: String) -> bool:
	for template in templates:
		if template.has("_uuid") and template["_uuid"] == uuid:
			return true
	return false


func stash_template(uuid: String, title: String, description: String, tags: Array[String], groups: Array[int], thumbnail: Image) -> void:
	template_stash[uuid] = {
		"_uuid": uuid,
		"title": title,
		"description": description,
		"groups": groups,
		"tags": tags,
		"thumbnail": thumbnail
	}


func is_stashed(uuid: String) -> bool:
	return template_stash.has(uuid)


func drop_stashed(uuid: String) -> void:
	template_stash.erase(uuid)


func clear_stash() -> void:
	template_stash.clear()


func overwrite_template(template_uuid: String, title: String, description: String, tags: Array[String], groups: Array[int], thumbnail: String) -> void:
	for template in templates:
		if template["_uuid"] != template_uuid:
			continue
		template["title"] = title
		template["description"] = description
		template["groups"] = groups
		template["tags"] = tags
		template["thumbnail"] = thumbnail
		break


func erase_template(template_uuid: String) -> void:
	for template_idx in range(templates.size()):
		if templates[template_idx]["_uuid"] == template_uuid:
			templates.remove_at(template_idx)
			break


func delete_template_thumbnail(template_uuid: String) -> void:
	for template_idx in range(templates.size()):
		if templates[template_idx]["_uuid"] == template_uuid:
			if not templates[template_idx]["thumbnail"].is_empty() and FileAccess.file_exists(get_thumbnail_path() + templates[template_idx]["thumbnail"]):
				OS.move_to_trash(get_thumbnail_path() + templates[template_idx]["thumbnail"])
			break


func get_template(template_uuid: String) -> Dictionary:
	for template_idx in range(templates.size()):
		if templates[template_idx]["_uuid"] == template_uuid:
			return templates[template_idx].duplicate()
	return {}


func get_stash(stash_uuid: String) -> Dictionary:
	return template_stash[stash_uuid]


func get_template_thumbnail_path(uuid: String) -> String:
	for template in templates:
		if template["_uuid"] == uuid:
			return template["thumbnail"]
	return ""


func save() -> void:
	ResourceSaver.save(self, get_file_path())
