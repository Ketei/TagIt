extends Tree


const SET_DESC_DIALOG = preload("res://scenes/dialogs/set_desc_dialog.tscn")

signal group_renamed(id: int, new_name: String)
signal group_desc_updated(id: int, new_desc: String)
signal group_deleted(id: int)

const BIN_ICON = preload("res://icons/bin_icon.svg")
const EDIT_ICON = preload("res://icons/edit_icon.svg")

var root_tree: TreeItem = null


func _ready() -> void:
	root_tree = create_item()
	button_clicked.connect(on_button_pressed)
	item_edited.connect(on_item_edited)


func create_group(group_name: String, group_desc: String, group_id: int) -> void:
	var new_group: TreeItem = create_item(root_tree)
	
	new_group.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	
	new_group.set_text(0, group_name)
	new_group.set_metadata(0, {"id": group_id, "desc": group_desc})
	
	new_group.add_button(0, EDIT_ICON, 0, false, "Edit Description")
	new_group.add_button(0, BIN_ICON, 1, false, "Delete Group")


func on_item_edited() -> void:
	var edited_item: TreeItem = get_edited()
	
	match get_edited_column():
		0:
			group_renamed.emit(edited_item.get_metadata(0)["id"], edited_item.get_text(0))


func on_button_pressed(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			group_desc_updated.emit(item.get_metadata(0)["id"], item.get_metadata(0)["desc"])
		1:
			group_deleted.emit(item.get_metadata(0)["id"])
			item.free()
