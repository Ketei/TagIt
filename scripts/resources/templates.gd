class_name TemplateResource
extends Resource


const TEMPLATE_PATH: String = "user://templates/templates.tres"
const TEMPLATE_THUMBNAILS: String = "user://templates/thumbnails/"
@export var templates: Array[Dictionary] = []
@export var template_map: Dictionary[String, Dictionary] = {}
var template_stash: Dictionary = {}


static func get_thumbnails_folder() -> String:
	var path: String = ProjectSettings.globalize_path(TEMPLATE_THUMBNAILS)
	if not path.ends_with("/"):
		path += "/"
	return path


static func get_thumbnail_path(thumb_hash: String) -> String:
	var path: String = ProjectSettings.globalize_path(TEMPLATE_THUMBNAILS)
	return path.path_join(thumb_hash) + ".webp"


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
	var uuid: String = UUID.generate_new()
	templates.append({
		"_uuid": uuid,
		"title": title,
		"description": description,
		"groups": groups.duplicate(),
		"tags": tags.duplicate(),
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


func save_template(template: TagItTemplate) -> bool:
	if template._uuid.is_empty() or template_map.has(template._uuid):
		return false
	
	var data: Dictionary[String, Variant] = {
		"_uuid": template._uuid,
		"title": template.title,
		"description": template.description,
		"groups": template.groups.duplicate(),
		"tags": template.tags.duplicate()}
	
	template_map[template._uuid] = data
	return true


func erase_template(template_uuid: String) -> void:
	if not template_map.has(template_uuid):
		return
	
	var t_hash: String = template_uuid.replace("-", "")
	var thumb_path: String = get_thumbnail_path(t_hash)
	if not thumb_path.is_empty() and FileAccess.file_exists(thumb_path):
		OS.move_to_trash(thumb_path)
		
	template_map.erase(template_uuid)


func get_template(template_uuid: String) -> TagItTemplate:
	if not template_map.has(template_uuid):
		return null
	
	var data: Dictionary = template_map[template_uuid]
	var template: TagItTemplate = TagItTemplate.new()
	
	var groups_data: Variant = data.get("groups")
	var tags_data: Variant = data.get("tags")
	var thumbnail_file: String = TemplateResource.get_thumbnail_path(template_uuid.replace("-", ""))
	
	template._uuid = template_uuid
	template.title = data.get("title", "")
	template.description = data.get("description", "")
	if typeof(groups_data) == TYPE_ARRAY:
		template.groups = groups_data.duplicate()
	if typeof(tags_data) == TYPE_ARRAY:
		template.tags = tags_data.duplicate()
	
	if FileAccess.file_exists(thumbnail_file):
		var img: Image = Image.load_from_file(thumbnail_file)
		if img != null:
			var tex: ImageTexture = ImageTexture.create_from_image(img)
			template._thumbnail = tex
	
	return template


func get_stash(stash_uuid: String) -> Dictionary:
	return template_stash[stash_uuid]


func get_template_thumbnail_path(uuid: String) -> String:
	for template in templates:
		if template["_uuid"] == uuid:
			return template["thumbnail"]
	return ""


func get_template_uuids() -> Array[String]:
	return Arrays.create_typed(TYPE_STRING, template_map.keys())


func has_template(uid: String) -> bool:
	return template_map.has(uid)


func save() -> void:
	ResourceSaver.save(self, get_file_path())
