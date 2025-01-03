extends IDTree


var root_tree: TreeItem = null


func _ready() -> void:
	root_tree = create_item()


func add_tag(text: String, id: int = -1) -> void:
	var new_tag: TreeItem = create_item(root_tree)
	new_tag.set_text(0, text)
	new_tag.set_metadata(0, id)


func get_existing_ids() -> Array[int]:
	var existing_parents: Array[int] = []
	for parent in root_tree.get_children():
		if parent.get_metadata(0) != -1:
			existing_parents.append(parent.get_metadata(0))
	return existing_parents


func get_new_tags() -> Array[String]:
	var new_parents: Array[String] = []
	for parent in root_tree.get_children():
		if parent.get_metadata(0) == -1:
			new_parents.append(parent.get_text(0))
	return new_parents


func has_tag(text: String) -> bool:
	return has_item(root_tree, text, 0)


func clear_tags() -> void:
	for tag in root_tree.get_children():
		tag.free()


func delete_selected() -> void:
	var next_target: TreeItem = get_next_selected(root_tree)
	while next_target != null:
		next_target.free()
		next_target = get_next_selected(root_tree)
