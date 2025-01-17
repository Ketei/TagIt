extends IDTree


signal category_icon_changed(cat_id: int, icon_id: int)
signal set_category_desc_pressed(id: int)
signal set_category_color_pressed(id: int, color: String)
signal category_deleted(id: int)

const BIN_ICON = preload("res://icons/bin_icon.svg")
const EDIT_ICON = preload("res://icons/edit_icon.svg")
const BRUSH_ICON = preload("res://icons/brush_icon.svg")

var root_tree: TreeItem = null
var icon_string: String = "":
	set(new_string):
		icon_string = new_string
		for cat in root_tree.get_children():
			cat.set_text(1, icon_string)
var icon_range: int = 0:
	set(new_range):
		icon_range = new_range
		for cat in root_tree.get_children():
			if icon_range < cat.get_range(1):
				cat.set_range(1, 0)
				category_icon_changed.emit(cat.get_metadata(0)["id"], 0)
			cat.set_range_config(1, 0, icon_range, 1.0)


func _ready() -> void:
	root_tree = create_item()
	
	set_column_title(0, "Name")
	set_column_title(1, "Icon")
	
	set_column_expand(0, true)
	set_column_expand(1, true)
	
	set_column_expand_ratio(0, 2)
	set_column_expand_ratio(1, 3)
	
	button_clicked.connect(on_button_clicked)
	item_edited.connect(on_item_edited)
	SingletonManager.TagIt.category_created.connect(_on_category_created)
	SingletonManager.TagIt.category_icon_updated.connect(_on_category_icon_updated)
	SingletonManager.TagIt.category_color_updated.connect(_on_category_color_updated)


func _on_category_created(category_id: int) -> void:
	var category_info: Dictionary = SingletonManager.TagIt.get_category_data(category_id)
	create_category(
			category_info["name"],
			category_info["description"],
			category_id,
			0,
			SingletonManager.TagIt.get_icon_texture(1),
			SingletonManager.TagIt.get_category_icon_color(1))


func _on_category_icon_updated(cat_id: int, icon_id: int) -> void:
	set_category_icon(cat_id, SingletonManager.TagIt.get_icon_texture(icon_id))


func _on_category_color_updated(cat_id: int, color: String) -> void:
	set_category_color(cat_id, color)
	

func create_category(cat_name: String, cat_desc: String, id: int, initial_range: int, icon_texture: Texture2D, icon_color: Color) -> void:
	var new_category: TreeItem = create_item(root_tree)
	
	new_category.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	new_category.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	
	new_category.set_text(0, cat_name)
	new_category.set_text(1, icon_string)
	new_category.set_range_config(1, 0, icon_range, 1)
	
	new_category.set_range(1, initial_range)
	
	new_category.set_icon(0, icon_texture)
	new_category.set_icon_modulate(0, icon_color)
	
	new_category.set_editable(0, false)
	new_category.set_editable(1, id != 1)
	
	new_category.set_selectable(0, false)
	
	new_category.add_button(1, EDIT_ICON, 0, false, "Edit Description")
	new_category.add_button(1, BRUSH_ICON, 1, false, "Edit Color")
	new_category.add_button(1, BIN_ICON, 2, id == 1, "Delete Category")
	new_category.set_metadata(0, {"id": id, "desc": cat_desc})


func on_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			set_category_desc_pressed.emit(item.get_metadata(0)["id"])
		1:
			set_category_color_pressed.emit(item.get_metadata(0)["id"], item.get_icon_modulate(0).to_html(false))
		2:
			category_deleted.emit(item.get_metadata(0)["id"])
			item.free()


func set_category_color(cat_id: int, color: String) -> void:
	for category in root_tree.get_children():
		if category.get_metadata(0)["id"] == cat_id:
			category.set_icon_modulate(0, Color.from_string(color, Color.WHITE))
			break


func set_category_icon(cat_id: int, icon_texture: Texture2D) -> void:
	for category in root_tree.get_children():
		if category.get_metadata(0)["id"] == cat_id:
			category.set_icon(0, icon_texture)
			break


func on_item_edited() -> void:
	var edited: TreeItem = get_edited()
	
	match get_edited_column():
		1:
			category_icon_changed.emit(edited.get_metadata(0)["id"], edited.get_range(1))
