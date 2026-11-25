extends IDTree


signal suggestions_dropped(suggestions: Array[String])
signal groups_dropped(groups: Dictionary[int, Dictionary])
signal move_tags_to_list_pressed(list: String, tags: Array[String])
signal move_tags_to_new_list_pressed(tags: Array[String])
signal search_in_wiki_pressed(tag: String)
signal tags_changed


var _current_alt: int = 0
var alt_list_submenu: PopupMenu = null
@onready var main_tagger_popup: RightClickPopupMenu = $MainTaggerPopup

var _current_tags: Dictionary[String, TagItem] = {}
var _tag_trees: Dictionary[String, TreeItem] = {}


func _ready() -> void:
	create_item()
	set_column_expand(0, true)
	
	alt_list_submenu = PopupMenu.new()
	alt_list_submenu.add_item("- New list -")
	alt_list_submenu.add_item("* Common List *")
	
	main_tagger_popup.add_item("Wiki", 0)
	
	alt_list_submenu.set_item_disabled(1, true)
	main_tagger_popup.add_submenu_node_item("Move to List", alt_list_submenu, 1)
	main_tagger_popup.add_item("Remove", 2)
	
	focus_exited.connect(on_focus_lost)
	item_mouse_selected.connect(_on_item_mouse_selected)
	alt_list_submenu.index_pressed.connect(_on_submenu_index_pressed)
	main_tagger_popup.id_pressed.connect(_on_main_popup_id_pressed)
	
	SingletonManager.TagIt.tag_created.connect(on_tag_created)
	SingletonManager.TagIt.tags_validity_updated.connect(on_tag_validity_updated)
	SingletonManager.TagIt.tags_created.connect(_on_tags_created)


func _input(event: InputEvent) -> void:
	if has_focus() and event is InputEventKey:
		if get_selected() != null and Input.is_action_just_pressed(&"ui_text_delete"):
			var next_target:= get_next_selected(null)
			while next_target != null:
				var next: TreeItem = get_next_selected(next_target)
				next_target.free()
				next_target = next
			tags_changed.emit()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_A and not event.is_echo() and Input.is_key_pressed(KEY_CTRL):
			select_all()


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	
	var type: Variant = data.get("type")
	if type != "suggestions" and type != "group_tags":
		return false
	
	return true


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
	match data["type"]:
		"suggestions":
			if data["tag_names"].is_empty():
				return
			suggestions_dropped.emit(data["tag_names"].duplicate())
		"group_tags":
			if data["group_tags"].is_empty():
				return
			groups_dropped.emit(data["group_tags"].duplicate(true))


func get_used_tags() -> Dictionary[String, int]:
	var result: Dictionary[String, int] = {}
	for tag in _current_tags:
		var item: TagItem = _current_tags[tag]
		result[item.tag_text] = item.tag_id
	return result


func _on_tags_created(tag_names: Array[String]) -> void:
	for tag in tag_names:
		on_tag_created(tag, SingletonManager.TagIt.get_tag_id(tag))


func _on_item_mouse_selected(_mouse_position: Vector2, mouse_button_index: int) -> void:
	if mouse_button_index != MOUSE_BUTTON_RIGHT:
		return
	var selected: Array[String] = get_selected_tags()
	var on_wiki: bool = SingletonManager.TagIt.has_tag_data(selected[0]) if not selected.is_empty() and selected.size() == 1 else false
	
	main_tagger_popup.set_item_disabled(0, not on_wiki)
	main_tagger_popup.set_item_metadata(0, not on_wiki)
	
	main_tagger_popup.show_in_bounds(get_global_mouse_position())


func _on_alt_list_switched(list_idx: int) -> void:
	if _current_alt != -1:
		alt_list_submenu.set_item_disabled(_current_alt + 1, false)
	
	if list_idx != -1:
		alt_list_submenu.set_item_disabled(list_idx + 1, true)
	
	_current_alt = list_idx


func _on_main_popup_id_pressed(id: int) -> void:
	if id == 0:
		search_in_wiki_pressed.emit(
				get_selected().get_text(0))
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
			get_selected_tags())
	else:
		move_tags_to_list_pressed.emit(
				main_tagger_popup.get_item_metadata(index),
				get_selected_tags())


func select_all() -> void:
	for tag in get_root().get_children():
		tag.select(0)


func delete_alt_list(id: String) -> void:
	var index: int = -1
	for idx in alt_list_submenu.item_count:
		if alt_list_submenu.get_item_metadata(idx) == id:
			alt_list_submenu.remove_item(idx)
			index = idx
			break
	
	if _current_alt == index:
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


func add_alt_list(alt_list_name: String, id: String) -> void:
	alt_list_submenu.add_item(alt_list_name)
	alt_list_submenu.set_item_metadata(-1, id)


func clear_popup_alts() -> void:
	for alt in range(alt_list_submenu.item_count - 1, 1, -1):
		alt_list_submenu.remove_item(alt)
	_current_alt = 0
	alt_list_submenu.set_item_disabled(1, true)


func _on_tags_moved(result: bool, indexes: Array[int]) -> void:
	if result:
		indexes.sort_custom(Arrays.sort_custom_desc)
		for index in indexes:
			get_root().get_child(index).free()


func on_focus_lost() -> void:
	deselect_all()


func add_tag(tag_id: int, tag_name: String, tooltip: String = "", icon: Texture2D = null, category: int = 0, color: Color = Color.WHITE) -> TreeItem:
	if _current_tags.has(tag_name):
		return null
	
	var new_tag: TreeItem = get_root().create_child()
	
	new_tag.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	
	if icon != null:
		new_tag.set_icon(0, icon)
		new_tag.set_icon_modulate(0, color)
	
	new_tag.set_text(0, tag_name)
	new_tag.set_metadata(0, {"id": tag_id, "category": category, "valid": SingletonManager.TagIt.is_tag_valid(tag_id)})
	
	if not tooltip.is_empty():
		new_tag.set_tooltip_text(0, tooltip)
	
	if not new_tag.get_metadata(0)["valid"]:
		new_tag.set_custom_color(0, DataManager.INVALID_COLOR)
	
	var tag_item: TagItem = TagItem.new_tag(tag_id, tag_name)
	_current_tags[tag_name] = tag_item
	
	_tag_trees[tag_name] = new_tag
	
	return new_tag


func remove_tag_from_text(tag: String) -> void:
	if not _tag_trees.has(tag):
		return
	
	var item: TreeItem = _tag_trees[tag]
	
	_current_tags.erase(tag)
	_tag_trees.erase(tag)
	
	item.free()


func set_tag_id_text_color(tag: int, color: Color) -> void:
	if tag <= 0:
		return
	
	var text: String = ""
	var found: bool = false
	for item in _current_tags:
		if _current_tags[item].tag_id == tag:
			text = _current_tags[item].tag_text
			found = true
			break
	if not found:
		return
	var target: TreeItem = _tag_trees.get(text)
	if target == null:
		return
	target.set_custom_color(0, color)


func set_tag_text_color(tag: String, color: Color) -> void:
	var target: TreeItem = _tag_trees.get(tag)
	if target == null:
		return
	target.set_custom_color(0, color)


func clear_tag_text_color(tag: String) -> void:
	var target: TreeItem = _tag_trees.get(tag)
	if target == null:
		return
	target.clear_custom_color(0)


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
		if tag.get_metadata(0)["category"] == category_id:
			tag.set_icon(0, category_icon)


func update_tag(tag_id: int, _parents: Array[String], valid: bool) -> void:
	for tag in get_root().get_children():
		if tag.get_metadata(0)["id"] == tag_id:
			
			tag.get_metadata(0)["valid"] = valid
			
			if valid:
				tag.clear_custom_color(0)
			else:
				tag.set_custom_color(0, DataManager.INVALID_COLOR)
			break


func get_tags() -> Dictionary[String, Array]:
	var tag_id: Array[int] = []
	var non_id: Array[String] = []
	
	for tag in get_root().get_children():
		if tag.get_metadata(0)["id"] == -1:
			non_id.append(tag.get_text(0))
		else:
			tag_id.append(tag.get_metadata(0)["id"])
	
	var data: Dictionary[String, Array] = {
		"id": tag_id,
		"tag": non_id}
	
	return data


func get_all_tags_text() -> Array[String]:
	var all_tags: Array[String] = []
	for tag in get_root().get_children():
		all_tags.append(tag.get_text(0))
	return all_tags


func clear_tags() -> void:
	for tag in _tag_trees:
		_tag_trees[tag].free()
	
	_current_tags.clear()
	_tag_trees.clear()


func sort_tags_custom() -> void:
	if _current_tags.is_empty():
		return
	
	var root: TreeItem = get_root()
	var groups: Array[Array] = []
	var tags: Array[TreeItem] = root.get_children()
	
	var group_tags: Dictionary[int, Array] = {}
	
	for item in tags:
		var cat: int = item.get_metadata(0)["category"]
		if not group_tags.has(cat):
			var new_group: Array[TreeItem] = []
			group_tags[cat] = new_group
		group_tags[cat].append(item)
	
	for group in SingletonManager.TagIt.settings.custom_sorting:
		var new_group: Array[TreeItem] = []
		
		for group_id in group["group_ids"]:
			if group_tags.has(group_id):
				new_group.append_array(group_tags[group_id])
		
		if group["sorting"] == DataManager.SortingType.ALPHABETICAL:
			new_group.sort_custom(
					func (a:TreeItem,b:TreeItem) -> bool:
						return a.get_text(0) < b.get_text(0))
		else:
			var tag_names: Dictionary[String, Dictionary] = {}
			var tag_id_to_names: Dictionary [int, Dictionary]= {}# id: {tag, priority}
			var id_tags: Array[int] = []
			
			for tree in new_group:
				tag_names[tree.get_text(0)] = {"tree": tree, "priority": 0}
			
			# tag_name: TagId
			var valid_ids: Dictionary = SingletonManager.TagIt.get_tags_ids(
					Array(tag_names.keys(), TYPE_STRING, &"", null))
			
			for tag in tag_names:
				if valid_ids.has(tag):
					tag_id_to_names[valid_ids[tag]] = {"tag": tag, "priority": 0}
					id_tags.append(valid_ids[tag])
			
			# priority:[ids]
			var sorted_ids: Dictionary = SingletonManager.TagIt.sort_tag_ids_by_priority(id_tags)
			
			for priority in sorted_ids:
				for tag_id in sorted_ids[priority]:
					tag_id_to_names[tag_id]["priority"] = priority
			
			for ideed_tag in tag_id_to_names:
				tag_names[ tag_id_to_names[ideed_tag]["tag"] ]["priority"] = tag_id_to_names[ideed_tag]["priority"]
			
			var groupings: Array[Dictionary] = []
			
			for tag_name in tag_names:
				var group_dict: Dictionary = {
					"tree": tag_names[tag_name]["tree"],
					"priority": tag_names[tag_name]["priority"]}
				groupings.append(group_dict)
			
			groupings.sort_custom(
					func (a:Dictionary,b:Dictionary) -> bool:
						if a["priority"] == b["priority"]:
							return a["tree"].get_text(0) < b["tree"].get_text
						else:
							return b["priority"] < a["priority"])
			
			var new_order: Array[TreeItem] = []
			
			for group_dict in groupings:
				new_order.append(group_dict["tree"])
			
			new_group = new_order
		
		if new_group.is_empty():
			continue
		
		Arrays.subtract_array(tags, new_group)
		groups.append(new_group)
	
	if groups.is_empty():
		return
	
	var index: int = 0
	for group in groups:
		for tag: TreeItem in group:
			if tag.get_index() != index:
				tag.move_before(root.get_child(index))
			index += 1
	
	for remaining_tag in tags:
		if remaining_tag.get_index() != index:
			remaining_tag.move_before(root.get_child(index))
		index += 1


func sort_tags_alphabetical(ascending: bool = true) -> void:
	if _tag_trees.is_empty():
		return
	
	var root: TreeItem = get_root()
	var tags: Array = _tag_trees.keys()
	tags.sort()
	if not ascending:
		tags.reverse()
	
	var idx: int = 0
	for tag in tags:
		var item: TreeItem = _tag_trees[tag]
		if item.get_index() != idx:
			item.move_before(root.get_child(idx))
		idx += 1


func sort_tags_category(ascending: bool = true) -> void:
	var root: TreeItem = get_root()
	var tags: Array[TreeItem] = []
	
	tags.sort_custom(
			func(a:TreeItem,b:TreeItem) -> bool:
				return a.get_metadata(0)["category"] < b.get_metadata(0)["category"])
	if not ascending:
		tags.reverse()
	
	var idx: int = 0
	for tag in tags:
		if tag.get_index() != idx:
			tag.move_before(root.get_child(idx))
		idx += 1
