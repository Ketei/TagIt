extends Tree


signal icon_deleted(id: int)

var root_tree: TreeItem = null
const BIN_ICON = preload("res://icons/bin_icon.svg")

func _ready() -> void:
	root_tree = create_item()
	set_column_expand(0, false)
	set_column_expand(1, true)
	
	set_column_custom_minimum_width(0, 16)
	
	button_clicked.connect(on_button_clicked)


func add_icon(icon_id: int, icon_name: String, icon_texture: Texture2D) -> void:
	var new_icon = create_item(root_tree)
	
	new_icon.set_cell_mode(0, TreeItem.CELL_MODE_ICON)
	new_icon.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	
	new_icon.set_icon(0, icon_texture)
	new_icon.set_text(1, icon_name)
	new_icon.set_metadata(1, icon_id)
	
	new_icon.add_button(1, BIN_ICON, 0, icon_id == 1, "Delete Icon")


func on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			icon_deleted.emit(item.get_metadata(1))
			item.free()
