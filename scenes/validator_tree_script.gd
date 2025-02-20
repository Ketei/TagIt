extends Tree

var root_tree: TreeItem = null
var _modify_tags: Dictionary = {}


func _ready() -> void:
	set_column_title(0,"Tag")
	set_column_title(1, "Valid")
	root_tree = create_item()
	item_edited.connect(on_item_edited)
	set_column_expand(0, true)
	set_column_expand(1, false)
	set_column_custom_minimum_width(1, 25)


func set_tags(tag_ids: Array[int]) -> void:
	var tags_data: Dictionary = SingletonManager.TagIt.get_tags(tag_ids)
	for tag in tags_data:
		add_tag(
				tag,
				tags_data[tag]["name"],
				tags_data[tag]["is_valid"])


func add_tag(tag_id: int, tag_name: String, tag_valid: bool) -> void:
	var new_tag: TreeItem = create_item(root_tree)
	
	new_tag.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	new_tag.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	
	if _modify_tags.has(tag_id):
		new_tag.set_checked(1, _modify_tags[tag_id])
	else:
		new_tag.set_checked(1, tag_valid)
	
	new_tag.set_text(0, tag_name)
	
	new_tag.set_text_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	
	new_tag.set_metadata(0, tag_id)
	
	new_tag.set_editable(0, false)
	new_tag.set_editable(1, true)


func on_item_edited() -> void:
	var item: TreeItem = get_edited()
	_modify_tags[item.get_metadata(0)] = item.is_checked(1)


func get_tags_edited(to_valid: bool) -> Array[int]:
	var group_tags: Array[int] = []
	
	for tag in _modify_tags:
		if _modify_tags[tag] == to_valid:
			group_tags.append(tag)
	
	return group_tags


func clear_edited_tags() -> void:
	_modify_tags.clear()


func clear_tags() -> void:
	for tag in root_tree.get_children():
		tag.free()
