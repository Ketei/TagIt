extends Control

signal wizard_finished(success: bool)

const CHECK = preload("uid://ikfodwdw27dk")
const ERROR = preload("uid://dirhpw8rc5ll7")


var _used_list_ids: Dictionary[String, Variant] = {}

var _shared_tags: Array[String] = []
var _main_tags: Array[String] = []

var _main_id: String = ""
var _alt_id: String = ""

@onready var main_list_ln: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MainListLn
@onready var alt_list_ln: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/AltListLn
@onready var shared_tags_tree: Tree = $PanelContainer/MarginContainer/VBoxContainer/SharedTagsTree
@onready var cancel_alts_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonContainer/CancelAltsBtn
@onready var create_alts_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/ButtonContainer/CreateAltsBtn

@onready var warning_main: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/WarningMain
@onready var warning_alt: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/WarningAlt


func _ready() -> void:
	main_list_ln.text_changed.connect(_on_list_text_changed)
	alt_list_ln.text_changed.connect(_on_list_text_changed)
	shared_tags_tree.create_item()
	
	shared_tags_tree.set_column_title(0, "Tag")
	shared_tags_tree.set_column_title(1, "Shared List")
	
	shared_tags_tree.set_column_expand(0, true)
	shared_tags_tree.set_column_expand(1, true)
	
	shared_tags_tree.set_column_expand_ratio(0, 2)
	shared_tags_tree.set_column_expand_ratio(1, 1)
	
	
	create_alts_btn.pressed.connect(_on_create_pressed)
	cancel_alts_btn.pressed.connect(_on_cancel_pressed)


func clear() -> void:
	shared_tags_tree.clear()
	shared_tags_tree.create_item()
	
	main_list_ln.text = "Main Version"
	alt_list_ln.text = "Alternate Version"
	_shared_tags.clear()
	_main_tags.clear()
	_used_list_ids.clear()
	_main_id = "Main Version"
	_alt_id = "Alternate Version"
	
	warning_main.texture = ERROR
	warning_alt.texture = ERROR
	
	create_alts_btn.disabled = false


func set_shared_tags(tags: Array) -> void:
	shared_tags_tree.clear()
	shared_tags_tree.create_item()
	var root: TreeItem = shared_tags_tree.get_root()
	
	for tag in tags:
		var new_base: TreeItem = root.create_child()
		new_base.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		new_base.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
		
		new_base.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
		
		new_base.set_editable(0, false)
		new_base.set_editable(1, true)
		
		new_base.set_text(0, tag)
		new_base.set_checked(1, true)


func set_used_list_ids(ids: Array) -> void:
	_used_list_ids.clear()
	for id in ids:
		_used_list_ids[id] = null
	_validate_list_ids()


func get_selected_shared() -> Array[String]:
	return _shared_tags.duplicate()


func get_selected_main() -> Array[String]:
	return _main_tags.duplicate()


func get_main_list_id() -> String:
	return _main_id


func get_alt_list_id() -> String:
	return _alt_id


func _on_create_pressed() -> void:
	visible = false
	for item in shared_tags_tree.get_root().get_children():
		if item.is_checked(1):
			_shared_tags.append(item.get_text(0))
		else:
			_main_tags.append(item.get_text(0))
	
	wizard_finished.emit(true)


func _on_cancel_pressed() -> void:
	visible = false
	wizard_finished.emit(false)


func _on_list_text_changed(_text: String) -> void:
	_validate_list_ids()


func _validate_list_ids() -> void:
	var main_text: String = main_list_ln.text.strip_edges()
	var alt_text: String = alt_list_ln.text.strip_edges()
	var main_issue: bool = main_text.is_empty() or _used_list_ids.has(main_text)
	var alt_issue: bool = alt_text.is_empty() or _used_list_ids.has(alt_text)
	if main_issue or alt_issue:
		create_alts_btn.disabled = true
		warning_main.texture = ERROR if main_issue else CHECK
		warning_alt.texture = ERROR if alt_issue else CHECK
	else:
		create_alts_btn.disabled = false
		warning_main.texture = CHECK
		warning_alt.texture = CHECK
