extends VBoxContainer

const PREFIX_CREATION_DIALOG = preload("res://scenes/dialogs/prefix_creation_dialog.tscn")
const BIN_ICON = preload("res://icons/bin_icon.svg")
var tool_description: String = "Create tag shortcuts with prefixes."
var requires_save: bool = false
const TOOL_ID: String = "prefixes"

@onready var alias_tree: Tree = $AliasTree
@onready var test_line_edit: LineEdit = $TestContainer/TestLineEdit
@onready var test_prefix_btn: Button = $TestContainer/TestPrefixBtn
@onready var test_prefix_lbl: Label = $TestContainer/PanelContainer/TestPrefixLbl

@onready var create_alias_btn: Button = $HBoxContainer/CreateAliasBtn


func _ready() -> void:
	alias_tree.create_item()
	alias_tree.set_column_title(0, "Prefix Symbol")
	alias_tree.set_column_title(1, "Tag Formatting")
	alias_tree.set_column_expand_ratio(0, 1)
	alias_tree.set_column_expand_ratio(1, 2)
	
	for prefix_dict in TagIt.get_prefixes_data():
		create_prefix(prefix_dict["prefix"], prefix_dict["format"])
	
	create_alias_btn.pressed.connect(on_create_prefix_pressed)
	alias_tree.button_clicked.connect(_on_alias_button_clicked)
	alias_tree.item_edited.connect(_on_prefix_edited)
	test_line_edit.text_submitted.connect(on_test_text_submit)
	test_prefix_btn.pressed.connect(on_test_prefix_btn_pressed)


func on_create_prefix_pressed() -> void:
	var existing := PackedStringArray()
	for prefix in alias_tree.get_root().get_children():
		existing.append(prefix.get_text(0))
	var new_window := PREFIX_CREATION_DIALOG.instantiate()
	new_window.existing_prefixes = existing
	add_child(new_window)
	new_window.show()
	var result = await new_window.prefix_submitted
	if result[0]:
		create_prefix(result[1])
		TagIt.add_prefix(result[1], "")
	new_window.queue_free()


func create_prefix(prefix_symbol: String, prefix_formatting: String = "") -> void:
	var new_alias: TreeItem = alias_tree.get_root().create_child()
	new_alias.set_text(0, prefix_symbol)
	new_alias.set_text(1, prefix_formatting)
	new_alias.set_editable(1, true)
	new_alias.set_selectable(0, false)
	new_alias.add_button(1, BIN_ICON, 0, false, "Delete Alias")


func on_test_text_submit(text: String) -> void:
	var clean_text: String = text.strip_edges()
	var parts: Array[String] = TagIt.format_prefix(clean_text)
	test_prefix_lbl.text = ", ".join(parts)


func on_test_prefix_btn_pressed() -> void:
	on_test_text_submit(test_line_edit.text)


func _on_alias_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			TagIt.erase_prefix(item.get_text(0))
			item.free()


func _on_prefix_edited() -> void:
	if alias_tree.get_edited_column() != 1:
		return
	var edited: TreeItem = alias_tree.get_edited()
	TagIt.update_prefix(edited.get_text(0), edited.get_text(1))


func on_save_pressed() -> void:
	return
