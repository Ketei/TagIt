extends ConfirmationDialog


signal tags_selected(tags: Array[String])

@onready var tags_tree: Tree = $VBoxContainer/TagsTree
@onready var deselect_all_btn: Button = $VBoxContainer/HBoxContainer/DeselectAllBtn
@onready var select_all_btn: Button = $VBoxContainer/HBoxContainer/SelectAllBtn


func _ready() -> void:
	tags_tree.create_item()
	confirmed.connect(on_ok_pressed)
	canceled.connect(on_cancel_pressed)
	select_all_btn.pressed.connect(set_select_items.bind(true))
	deselect_all_btn.pressed.connect(set_select_items.bind(false))


func set_select_items(select: bool) -> void:
	for item in tags_tree.get_root().get_children():
		item.set_checked(0, select)


func load_tags(tags: Array[String]) -> void:
	for existing in tags_tree.get_root().get_children():
		existing.free()
	
	var tags_sorted: Array[String] = tags.duplicate()
	
	tags_sorted.sort_custom(Arrays.sort_custom_alphabetically_asc)
	
	for tag in tags:
		var new_tag: TreeItem = tags_tree.get_root().create_child()
		new_tag.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_tag.set_text(0, tag)
		new_tag.set_editable(0, true)


func on_ok_pressed() -> void:
	var tags: Array[String] = []
	for item in tags_tree.get_root().get_children():
		if item.is_checked(0):
			tags.append(item.get_text(0))
	tags_selected.emit(tags)


func on_cancel_pressed() -> void:
	tags_selected.emit(Array([], TYPE_STRING, &"", null))
