extends IDTree


signal suggestions_dropped(suggestions: Array[String])
signal move_tags_to_list_pressed(list_idx: int, tags: Array[String], indexes: Array[int])
signal move_tags_to_new_list_pressed(tags: Array[String], indexes: Array[int])
signal search_in_wiki_pressed(tag: String)
signal tags_changed


var _current_alt: int = 0
var alt_list_submenu: PopupMenu = null
@onready var main_tagger_popup: RightClickPopupMenu = $MainTaggerPopup


func _ready() -> void:
	create_item()
	set_column_expand(0, true)
	
	alt_list_submenu = PopupMenu.new()
	alt_list_submenu.add_item("- New list -")
	alt_list_submenu.add_item("* Common List *")
	main_tagger_popup.add_item("Open in Wiki", 0)
	alt_list_submenu.set_item_disabled(1, true)
	main_tagger_popup.add_submenu_node_item("Move to Alt List", alt_list_submenu, 1)
	main_tagger_popup.add_item("Delete", 2)
	
	focus_exited.connect(on_focus_lost)
	item_mouse_selected.connect(_on_item_mouse_selected)
	alt_list_submenu.index_pressed.connect(_on_submenu_index_pressed)
	main_tagger_popup.id_pressed.connect(_on_main_popup_id_pressed)
	
	SingletonManager.TagIt.tag_created.connect(on_tag_created)
	SingletonManager.TagIt.tags_validity_updated.connect(on_tag_validity_updated)
	SingletonManager.TagIt.tags_created.connect(_on_tags_created)


func _input(event: InputEvent) -> void:
	if has_focus() and get_selected() != null and event.is_action_pressed(&"ui_text_delete"):
		var next_target:= get_next_selected(null)
		while next_target != null:
			var next: TreeItem = get_next_selected(next_target)
			next_target.free()
			next_target = next
		tags_changed.emit()
		get_viewport().set_input_as_handled()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has_all(["type", "tag_names", "tree", "tree_type"]) and data["type"] == "tag_array"


func _get_drag_data(_at_position: Vector2) -> Variant:
	if get_next_selected(null) == null:
		return null
	
	var selected_tags: Array[String] = []
	
	var current: TreeItem = get_next_selected(null)
	
	while current != null:
		selected_tags.append(current.get_text(0))
		current = get_next_selected(current)
	
	var tags_label := Label.new()
	var tag_count: int = selected_tags.size()
	tags_label.text = str("    ", tag_count, " tag")
	if 1 != tag_count:
		tags_label.text += "s"
	set_drag_preview(tags_label)
	return {
		"type": "tag_list",
		#"tag_ids": get_selected_ids(),
		"tag_names": selected_tags,
		"tree_type": 1,
		"tree": self}


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data["tag_names"].is_empty():
		return
	var ids: Array[int] = []
	var names: Array[String] = []
	
	for tag in data["tag_names"]:
		if SingletonManager.TagIt.has_tag(tag) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(tag)):
			ids.append(SingletonManager.TagIt.get_tag_id(tag))
		else:
			names.append(tag)
	
	var tags_data: Dictionary = SingletonManager.TagIt.get_tags_data(ids)
	var categories: Dictionary = SingletonManager.TagIt.get_categories()
	var last_tag: TreeItem = null
	
	for data_id in tags_data:
		last_tag = add_tag(
			data_id,
			tags_data[data_id]["tag"],
			tags_data[data_id]["tooltip"],
			SingletonManager.TagIt.get_icon_texture(categories[tags_data[data_id]["category"]]["icon_id"]),
			tags_data[data_id]["category"],
			Color.from_string(categories[tags_data[data_id]["category"]]["icon_color"], Color.WHITE))
	
	for generic_tag in names:
		last_tag = add_tag(
			-1,
			generic_tag,
			generic_tag,
			SingletonManager.TagIt.get_icon_texture(1),
			1,
			SingletonManager.TagIt.get_category_icon_color(1))
	
	if data["tree_type"] == 0:
		data["tree"].delete_tags(data["tag_names"])
	elif data["tree_type"] == 2:
		data["tree"].mark_tags(data["tag_names"])
	
	if data["tree_type"] == 0 or data["tree_type"] == 1:
		suggestions_dropped.emit(data["tag_names"])
	
	scroll_to_item(last_tag)


func _on_tags_created(tag_names: Array[String]) -> void:
	for tag in tag_names:
		on_tag_created(tag, SingletonManager.TagIt.get_tag_id(tag))


func _on_item_mouse_selected(_mouse_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_RIGHT:
		return
	var selected: Array[String] = get_selected_tags()
	main_tagger_popup.set_item_disabled(0, !(selected.size() == 1) and SingletonManager.TagIt.has_tag(selected[0]))
	main_tagger_popup.show_in_bounds(get_global_mouse_position())


func _on_alt_list_switched(list_idx: int) -> void:
	if _current_alt != -1:
		alt_list_submenu.set_item_disabled(_current_alt + 1, false)
	
	if list_idx != -1:
		alt_list_submenu.set_item_disabled(list_idx + 1, true)
	
	_current_alt = list_idx


func _on_main_popup_id_pressed(id: int) -> void:
	if id == 0:
		search_in_wiki_pressed.emit(get_selected().get_text(0))
	elif id == 2:
		var to_delete: TreeItem = get_next_selected(null)
		while to_delete != null:
			var next: TreeItem = get_next_selected(to_delete)
			to_delete.free()
			to_delete = next
		tags_changed.emit()


func _on_submenu_index_pressed(index: int) -> void:
	if index == 0:
		move_tags_to_new_list_pressed.emit(
			get_selected_tags(),
			get_selected_array())
	else:
		move_tags_to_list_pressed.emit(
				index - 1,
				get_selected_tags(),
				get_selected_array())


func delete_alt_list(idx: int) -> void:
	alt_list_submenu.remove_item(idx + 1)
	if _current_alt == idx:
		_current_alt = -1


func get_selected_tags() -> Array[String]:
	var slected: Array[String] = []
	var initial: TreeItem = get_next_selected(null)
	
	while initial != null:
		slected.append(initial.get_text(0))
		initial = get_next_selected(initial)
	
	return slected


func get_selected_array() -> Array[int]:
	var result: Array[int] = []
	var initial: TreeItem = get_next_selected(null)
	
	while initial != null:
		result.append(initial.get_index())
		initial = get_next_selected(initial)
	
	return result


func add_alt_list(alt_list_name: String) -> void:
	alt_list_submenu.add_item(alt_list_name)


func _on_tags_moved(result: bool, indexes: Array[int]) -> void:
	if result:
		indexes.sort_custom(Arrays.sort_custom_desc)
		for index in indexes:
			get_root().get_child(index).free()


func on_focus_lost() -> void:
	deselect_all()


func add_tag(tag_id: int, tag_name: String, tooltip: String, icon: Texture2D, category: int, color: Color) -> TreeItem:
	if has_item(get_root(), tag_name, 0):
		return null
	
	var new_tag: TreeItem = get_root().create_child()
	
	new_tag.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	
	new_tag.set_icon(0, icon)
	new_tag.set_icon_modulate(0, color)
	
	new_tag.set_text(0, tag_name)
	new_tag.set_metadata(0, {"id": tag_id, "category": category, "valid": SingletonManager.TagIt.is_tag_valid(tag_id)})
	
	new_tag.set_tooltip_text(0, tooltip)
	
	if not new_tag.get_metadata(0)["valid"]:
		new_tag.set_custom_color(0, DataManager.INVALID_COLOR)
	
	return new_tag


func has_tag(tag_text: String) -> bool:
	for tag in get_root().get_children():
		if tag.get_text(0) == tag_text:
			return true
	return false


func on_tag_validity_updated(tag_ids: Array[int], valid: bool) -> void:
	for id in tag_ids:
		for tag in get_root().get_children():
			if tag.get_metadata(0)["id"] == id:
				tag.get_metadata(0)["valid"] = valid
				if not valid:
					tag.set_custom_color(0, DataManager.INVALID_COLOR)
				else:
					tag.clear_custom_color(0)
				break


func on_tag_created(tag_name: String, tag_id: int) -> void:
	for tag in get_root().get_children():
		if tag.get_text(0) == tag_name:
			if SingletonManager.TagIt.has_data(tag_id):
				var cat_id: Dictionary = SingletonManager.TagIt.get_tag_data_columns(tag_id, ["category_id", "tooltip"])
				var category := SingletonManager.TagIt.get_category_data(cat_id["category_id"])
				tag.set_icon(0, SingletonManager.TagIt.get_icon_texture(category["icon_id"]))
				tag.set_icon_modulate(0, Color.from_string(category["icon_color"], Color.WHITE))
				tag.get_metadata(0)["category"] = category
				if cat_id["tooltip"] != null:
					tag.set_tooltip_text(0, cat_id["tooltip"])
			var is_valid: bool = SingletonManager.TagIt.is_tag_valid(tag_id)
			tag.get_metadata(0)["id"] = tag_id
			tag.get_metadata(0)["valid"] = is_valid
			if not is_valid:
				tag.set_custom_color(0, DataManager.INVALID_COLOR)
			else:
				tag.clear_custom_color(0)
			break


func update_category_color(category_id: int, category_color: String) -> void:
	var color := Color.from_string(category_color, Color.WHITE)
	for tag in get_root().get_children():
		if tag.get_metadata(0)["id"] == category_id:
			tag.set_icon_modulate(0, color)


func update_category_icon(category_id: int, category_icon: Texture2D) -> void:
	for tag in get_root().get_children():
		if tag.get_metadata(0) == category_id:
			tag.set_icon(0, category_icon)


func update_tag(tag_id: int, parents: Array[String], valid: bool) -> void:
	for tag in get_root().get_children():
		if tag.get_metadata(0)["id"] == tag_id:
			for parent in tag.get_children():
				parent.free()
			
			for new_parent in parents:
				var new_parent_item: TreeItem = create_item(tag)
				new_parent_item.set_text(0, new_parent)
			
			tag.get_metadata(0)["valid"] = valid
			
			if valid:
				tag.clear_custom_color(0)
			else:
				tag.set_custom_color(0, DataManager.INVALID_COLOR)
			break


func get_tags() -> Dictionary:
	var tag_id: Array[int] = []
	var non_id: Array[String] = []
	
	for tag in get_root().get_children():
		if tag.get_metadata(0)["id"] == -1:
			non_id.append(tag.get_text(0))
		else:
			tag_id.append(tag.get_metadata(0)["id"])
	
	return { "id": tag_id, "tag": non_id }


func get_all_tags_text() -> Array[String]:
	var all_tags: Array[String] = []
	for tag in get_root().get_children():
		all_tags.append(tag.get_text(0))
	return all_tags


func clear_tags() -> void:
	for tag in get_root().get_children():
		tag.free()
