extends Tree


var root_tree: TreeItem = null
const X_ICON = preload("res://icons/x_icon.svg")


func _ready() -> void:
	set_column_title(0,"Invalid Tags")
	root_tree = create_item()
	set_column_expand(0, true)


func add_tag(tag_name: String) -> void:
	var new_tag: TreeItem = create_item(root_tree)
	
	new_tag.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	
	new_tag.set_text(0, tag_name)
	
	new_tag.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	
	new_tag.set_editable(0, false)
	new_tag.set_metadata(0, false)
	new_tag.add_button(0, X_ICON, 0, false, "Remove Tag")


func has_tag(tag_str: String) -> bool:
	for child in root_tree.get_children():
		if child.get_text(0) == tag_str:
			return true
	return false


func get_new_invalid_tags() -> Array[String]:
	var group_tags: Array[String] = []
	
	for tag in root_tree.get_children():
		if not tag.get_metadata(0):
			group_tags.append(tag.get_text(0))
	
	return group_tags


func on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			item.free()


func clear_tags() -> void:
	for tag in root_tree.get_children():
		tag.free()


func set_all_tags_added() -> void:
	for tag in get_root().get_children():
		if tag.get_metadata(0) == false:
			tag.set_metadata(0, true)
