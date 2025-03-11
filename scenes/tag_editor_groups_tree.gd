extends Tree


var root_tree: TreeItem = null


func _ready() -> void:
	root_tree = create_item()


func search_group(text: String) -> void:
	for item in get_root().get_children():
		item.visible = text.is_empty() or item.get_text(0).containsn(text)


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


func sort_groups() -> void:
	var all_groups: Array[TreeItem] = get_root().get_children()
	all_groups.sort_custom(_sort_custom_alphabetical)
	
	all_groups[0].move_before(get_root().get_child(0))
	
	for idx in range(1, all_groups.size()):
		all_groups[idx].move_after(all_groups[idx - 1])


func _sort_custom_alphabetical(a: TreeItem, b: TreeItem) -> bool:
	return a.get_text(0).naturalnocasecmp_to(b.get_text(0)) < 0
