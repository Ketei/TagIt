extends Tree


const BIN_ICON = preload("res://icons/bin_icon.svg")
const ARROW_ICON = preload("res://icons/arrow_icon.svg")
var root_tree: TreeItem = null

func _ready() -> void:
	root_tree = create_item()
	set_column_title(0, "Old Name")
	set_column_title(2, "New Name")
	
	set_column_expand(0, true)
	set_column_expand(1, false)
	set_column_expand(2, true)
	set_column_expand(3, false)
	
	set_column_custom_minimum_width(1, 32)
	set_column_custom_minimum_width(3, 40)
	button_clicked.connect(on_button_clicked)


func add_alias(from: String, to: String) -> void:
	var new_alias: TreeItem = create_item(root_tree)
	
	new_alias.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	new_alias.set_cell_mode(1, TreeItem.CELL_MODE_ICON)
	new_alias.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
	
	new_alias.set_text(0, from)
	new_alias.set_text(2, to)
	
	new_alias.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	new_alias.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	
	new_alias.set_icon(1, ARROW_ICON)
	
	new_alias.add_button(3, BIN_ICON, 0, false, "Delete Alias")


func on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int):
	match id:
		0:
			var from_id: int = SingletonManager.TagIt.get_tag_id(item.get_text(0))
			SingletonManager.TagIt.remove_alias(from_id)
			item.free()


func clear_aliases() -> void:
	for alias in root_tree.get_children():
		alias.free()
