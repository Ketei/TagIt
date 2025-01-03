class_name TagResource
extends Resource


@export var tag_name: String = ""
@export var tag_category: Dictionary = {}
@export var tag_priority: int = 0
@export var tag_group: String = ""
@export var is_valid: bool = true
@export var aliases := PackedStringArray()
@export var parents := PackedStringArray()
@export var suggestions := PackedStringArray()
@export var group_suggestions := PackedStringArray()
@export var tooltip: String = ""
@export var wiki: String = ""


func set_category(category_name: String, category_icon: Image) -> void:
	tag_category = {"name": category_name, "icon": category_icon.save_webp_to_buffer()}
