class_name AppSettingsRes
extends Resource


const SETTINGS_PATH: String = "user://tagit_settings.tres"

@export var results_per_search: int = 20

@export var default_site: int = -1
@export var use_autofill: bool = true
@export var include_invalid: bool = false
@export var blacklist_removed: bool = false
@export var link_to_esix: bool = false
@export var load_wiki_images: bool = false
@export var wiki_images: int = 16
@export var wiki_thumbnail_size: int = 1
@export var hydrus_port: int = 0
@export var hydrus_key: String = ""
@export var tag_container_width: float = 630
@export var suggestions_height: float = 444
@export var request_suggestions: bool = false
@export var suggestion_relevancy: int = 45
@export var search_tags_on_esix: bool = false


static func get_settings() -> AppSettingsRes:
	if FileAccess.file_exists(SETTINGS_PATH):
		var res_preload: Resource = load(SETTINGS_PATH)
		if res_preload is AppSettingsRes:
			return res_preload
	return AppSettingsRes.new()


func has_valid_hydrus_login() -> bool:
	return 0 < hydrus_port and not hydrus_key.is_empty()


func save() -> void:
	ResourceSaver.save(self, SETTINGS_PATH)
