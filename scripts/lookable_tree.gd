class_name IDTree
extends Tree


func search_for_item(in_tree: TreeItem, what: String, in_cell: int) -> void:
	what = what.to_upper()
	var search_mode: int = 0
	var what_empty: bool = what.is_empty()
	if what.begins_with(DataManager.SEARCH_WILDCARD):
		search_mode += 1
	if what.ends_with(DataManager.SEARCH_WILDCARD):
		search_mode += 2
	
	match search_mode:
		0:
			for item in in_tree.get_children():
				item.visible = what_empty or Strings.nocasecmp_equal(item.get_text(in_cell), what)
		1:
			for item in in_tree.get_children():
				item.visible = what_empty or item.get_text(in_cell).to_upper().ends_with(what)
		2:
			for item in in_tree.get_children():
				item.visible = what_empty or item.get_text(in_cell).to_upper().begins_with(what)
		3:
			for item in in_tree.get_children():
				item.visible = what_empty or item.get_text(in_cell).containsn(what)


func has_item(in_tree: TreeItem, what: String, in_cell: int) -> bool:
	for item in in_tree.get_children():
		if item.get_text(in_cell) == what:
			return true
	return false
