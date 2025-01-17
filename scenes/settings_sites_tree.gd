extends Tree


const BIN_ICON = preload("res://icons/bin_icon.svg")
var root_tree: TreeItem = null


func _ready() -> void:
	root_tree = create_item()
	button_clicked.connect(on_button_clicked)


func add_site(site_name: String, site_id: int) -> void:
	var new_site: TreeItem = create_item(root_tree)
	
	new_site.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	
	new_site.set_text(0, site_name)
	new_site.set_metadata(0, site_id)
	new_site.add_button(0, BIN_ICON, 0, false, "Remove Site")


func on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int):
	match id:
		0:
			SingletonManager.TagIt.delete_site(item.get_metadata(0))
			item.free()
