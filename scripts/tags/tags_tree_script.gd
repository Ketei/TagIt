extends IDTree



signal edit_tag_pressed(tag_id: int)
signal export_tag_pressed(tag_id: int)
signal delete_tag_pressed(tag_id: int)

const CHECK_ICON = preload("res://icons/box_checked.svg")#("res://icons/check_icon.svg")#("res://icons/icon_checked.svg")
const CROSSED_ICON = preload("res://icons/box_unchecked.svg")#("res://icons/crossed_icon.svg")#("res://icons/check_cross_icon.svg")#

const EDIT_ICON = preload("res://icons/edit_icon.svg")
const BIN_ICON = preload("res://icons/bin_icon.svg")
const EXPORT_ICON = preload("res://icons/export_icon.svg")

var root_tree: TreeItem


func _ready() -> void:
	set_column_title(1, "Tag")
	set_column_title(2, "Category")
	set_column_title(3, "Priority")
	set_column_title(4, "Group")
	set_column_title(5, "Valid")
	set_column_title(6, "Actions") 
	
	set_column_custom_minimum_width(0, 40)
	set_column_custom_minimum_width(3, 80)
	set_column_custom_minimum_width(5, 80)
	set_column_custom_minimum_width(6, 120)
	set_column_expand(3, false)
	set_column_expand(6, false)
	set_column_expand(5, false)
	set_column_expand(0, false)
	
	root_tree = create_item()
	
	SingletonManager.TagIt.category_color_updated.connect(on_category_color_updated)
	SingletonManager.TagIt.category_icon_updated.connect(on_category_icon_updated)
	SingletonManager.TagIt.category_deleted.connect(on_category_deleted)
	button_clicked.connect(on_button_clicked)


func update_tag(tag_id: int, tag_name: String, tag_category: String, category_id: int, cat_icon: Texture2D, cat_color: Color, tag_priority: String, tag_group: String, group_id: int, valid: bool) -> void:
	for tag in root_tree.get_children():
		if tag.get_metadata(1) == tag_id:
			tag.set_icon_modulate(0, cat_color)
			tag.set_icon(0, cat_icon)
			tag.set_text(1, tag_name)
			tag.set_text(2, tag_category)
			tag.set_metadata(2, category_id)
			tag.set_text(3, tag_priority)
			tag.set_text(4, tag_group)
			tag.set_metadata(4, group_id)
			tag.set_icon(5, CHECK_ICON if valid else CROSSED_ICON)
			tag.set_icon_modulate(5, Color.LIGHT_GREEN if valid else Color.FIREBRICK)
			break


func on_category_deleted(cat_id: int) -> void:
	var new_color: Color = SingletonManager.TagIt.get_category_icon_color(1)
	for cat in root_tree.get_children():
		if cat.get_metadata(2) == cat_id:
			cat.set_icon_modulate(0, new_color)
			cat.set_icon(0, SingletonManager.TagIt.get_icon_texture(1))
			cat.set_text(2, "Generic")


func on_category_color_updated(cat_id: int, color: String) -> void:
	for cat in root_tree.get_children():
		if cat.get_metadata(2) == cat_id:
			cat.set_icon_modulate(0, Color.from_string(color, Color.WHITE))


func on_category_icon_updated(cat_id: int, icon_id: int) -> void:
	for cat in root_tree.get_children():
		if cat.get_metadata(2) == cat_id:
			cat.set_icon(0, SingletonManager.TagIt.get_icon_texture(icon_id))


func add_tag(id: int, tag_name: String, category: int, category_name: String, priority: int, group: int, group_name: String, icon: int, color: Color, valid: bool) -> void:
	var new_tag: TreeItem = create_item(root_tree)
	
	new_tag.set_cell_mode(0, TreeItem.CELL_MODE_ICON)
	new_tag.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	new_tag.set_cell_mode(2, TreeItem.CELL_MODE_STRING)
	new_tag.set_cell_mode(3, TreeItem.CELL_MODE_STRING)
	new_tag.set_cell_mode(4, TreeItem.CELL_MODE_STRING)
	new_tag.set_cell_mode(5, TreeItem.CELL_MODE_ICON)
	
	new_tag.set_icon(0, SingletonManager.TagIt.get_icon_texture(icon))
	new_tag.set_metadata(0, icon)
	new_tag.set_icon_modulate(0, color)
	
	new_tag.set_text(1, tag_name)
	new_tag.set_metadata(1, id)
	
	new_tag.set_text(2, category_name)
	new_tag.set_metadata(2, category)
	
	new_tag.set_text(3, str(priority))
	new_tag.set_metadata(3, priority)
	
	new_tag.set_text(4, group_name)
	new_tag.set_metadata(4, group)
	
	new_tag.set_icon(5, CHECK_ICON if valid else CROSSED_ICON)
	new_tag.set_icon_modulate(5, Color.LIGHT_GREEN if valid else Color.FIREBRICK)
	
	new_tag.set_editable(0, false)
	new_tag.set_editable(1, false)
	new_tag.set_editable(2, false)
	new_tag.set_editable(3, false)
	new_tag.set_editable(4, false)
	new_tag.set_editable(5, false)
	new_tag.set_editable(6, false)
	
	new_tag.set_text_alignment(2, HORIZONTAL_ALIGNMENT_CENTER)
	new_tag.set_text_alignment(3, HORIZONTAL_ALIGNMENT_CENTER)
	new_tag.set_text_alignment(4, HORIZONTAL_ALIGNMENT_CENTER)
	
	new_tag.add_button(6, EDIT_ICON, 0)#, false, "Edit Tag")
	new_tag.add_button(6, EXPORT_ICON, 1)#, false, "Export Tag")
	new_tag.add_button(6, BIN_ICON, 2)#, false, "Delete Tag")


func select_tag(idx: int) -> void:
	root_tree.select(idx)


func clear_tags() -> void:
	for tag in root_tree.get_children():
		tag.free()


func on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0: # Edit tag
			edit_tag_pressed.emit(item.get_metadata(1))
		1: # Export Tag
			export_tag_pressed.emit(item.get_metadata(1))
		2: # Delete Tag
			delete_tag_pressed.emit(item.get_metadata(1))
			item.free()
