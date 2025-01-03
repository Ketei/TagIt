extends Tree


var root_tree: TreeItem = null


func _ready() -> void:
	root_tree = create_item()


func add_group(group_id: int, group_name: String) -> void:
	var new_group: TreeItem = create_item(root_tree)
	
	new_group.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	
	new_group.set_text(0, group_name)
	new_group.set_metadata(0, group_id)
	
	new_group.set_editable(0, true)


func remove_group(group_id: int) -> void:
	for group in root_tree.get_children():
		if group.get_metadata(0) == group_id:
			group.free()
			break


func select_group(group_id: int, group_selected: bool) -> void:
	for group in root_tree.get_children():
		if group.get_metadata(0) == group_id:
			group.set_checked(0, group_selected)
			break


func get_checked_groups() -> Array[int]:
	var selected_groups: Array[int] = []
	for group in root_tree.get_children():
		if group.is_checked(0):
			selected_groups.append(group.get_metadata(0))
	return selected_groups


func reset_groups() -> void:
	for group in root_tree.get_children():
		group.set_checked(0, false)


func clear_groups() -> void:
	for group in root_tree.get_children():
		group.free()
