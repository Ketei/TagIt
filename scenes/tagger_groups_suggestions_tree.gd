extends Tree


signal suggestions_activated(suggestion_ids: Dictionary[int, Dictionary])
signal groups_deleted(groups: Array[int])


var groups: Dictionary[int, TreeItem] = {}


func _ready() -> void:
	create_item()
	item_activated.connect(on_item_activated)
	focus_exited.connect(on_focus_lost)


func _input(event: InputEvent) -> void:
	if has_focus() and event is InputEventKey and not event.is_echo():
		if Input.is_action_just_pressed(&"ui_text_delete"):
			var selected_groups: Array[TreeItem] = get_selected_tree_groups()
			if not selected_groups.is_empty():
				var deleted_groups: PackedInt64Array = []
				for grp in selected_groups:
					if not deleted_groups.has(grp.get_metadata(0)["id"]):
						deleted_groups.append(grp.get_metadata(0)["id"])
				groups_deleted.emit(deleted_groups)
				get_viewport().set_input_as_handled()


func _get_drag_data(_at_position: Vector2) -> Variant:
	var tags_selected: Dictionary = get_selected_data()
	var tags_label := Label.new()
	var tag_count: int = 0
	
	for id in tags_selected:
		tag_count += tags_selected[id]["tags"].size()
	
	tags_label.text = str("    ", tag_count, " tag")
	if 1 != tag_count:
		tags_label.text += "s"
	set_drag_preview(tags_label)
	return {
		"type": "group_tags",
		"group_tags": tags_selected}


func on_focus_lost() -> void:
	deselect_all()


func get_selected_data() -> Dictionary[int, Dictionary]:
	var data: Dictionary[int, Dictionary] = {}
	
	var selected: TreeItem = get_next_selected(null)
	if selected == null:
		return data
	
	while selected != null:
		if selected.get_metadata(0)["is_group"]:
			continue
		
		var group_parent: TreeItem = selected.get_parent()
		var meta: Dictionary = group_parent.get_metadata(0)
		var group_id: int = meta["id"]
		if not data.has(group_id):
			var group_data: Dictionary = {
				"name": group_parent.get_text(0),
				"tags": DictUtils.create_typed(TYPE_STRING, TYPE_INT)}
			data[group_id] = group_data
		var target: Dictionary = data[group_id]["tags"]
		
		target[selected.get_text(0)] = selected.get_metadata(0)["id"]
		selected = get_next_selected(selected)
	
	return data


func get_selected_names() -> Array[String]:
	var selected_ids: Array[String] = []
	var current: TreeItem = get_next_selected(null)
	while current != null:
		if not current.get_metadata(0)["is_group"]:
			selected_ids.append(current.get_text(0))
		current = get_next_selected(current)
	return selected_ids


func get_selected_tree_groups() -> Array[TreeItem]:
	var selected: Array[TreeItem] = []
	
	var current: TreeItem = get_next_selected(null)
	while current != null:
		if current.get_metadata(0)["is_group"]:
			selected.append(current)
		current = get_next_selected(current)
	
	return selected


func add_suggestions(suggestion_title: String, suggestions: Dictionary, group_id: int) -> void:
	var target: TreeItem = groups.get(group_id)
	
	if target == null:
		target = get_root().create_child()
		groups[group_id] = target
		target.set_text(0, Strings.title_case(suggestion_title))
		target.set_selectable(0, true)
		target.set_metadata(0, {"is_group": true, "id": group_id})
		target.collapsed = true
	
	var existing: Dictionary[int, TreeItem] = {}
	for item in target.get_children():
		existing[item.get_metadata(0)["id"]] = item
	
	for id in suggestions:
		if existing.has(id):
			continue
		
		var new_member: TreeItem = create_item(target)
		new_member.set_text(0, suggestions[id])
		new_member.set_metadata(0, {"is_group": false, "id": id})
		existing[id] = new_member


func has_tag_group(group_id: int) -> bool:
	for group in get_root().get_children():
		if group.get_metadata(0)["id"] == group_id:
			return true
	return false


func group_has_tag(group_id: int, tag: String) -> bool:
	if not groups.has(group_id):
		return false
	
	var target: TreeItem = groups[group_id]
	for tag_tree in target.get_children():
		if tag_tree.get_text(0) == tag:
			return true
	
	return false


func on_item_activated() -> void:
	var selected_data: Dictionary = get_selected_data()
	if selected_data.is_empty():
		return
	suggestions_activated.emit(selected_data)


func delete_tags(tags: Array[String]) -> void:
	for tag in tags:
		for child in get_root().get_children():
			if child.get_text(0) == tag:
				child.free()
				break


func get_all_groups() -> Array[int]:
	var all_tags: Array[int] = []
	all_tags.assign(groups.keys())
	return all_tags


func delete_selected() -> void:
	var current: TreeItem = get_next_selected(null)
	while current != null:
		var next = get_next_selected(current)
		current.free()
		current = next


func remove_data(group_data: Dictionary[int, Array]) -> void:
	for group_id in group_data:
		if not groups.has(group_id):
			continue
		
		var target: TreeItem = groups[group_id]
		var items: Dictionary[String, TreeItem] = {}
		for child in target.get_children():
			items[child.get_text(0)] = child
		
		for tag in group_data[group_id]:
			if items.has(tag):
				items[tag].free()
				items.erase(tag)
		
		if items.is_empty():
			target.free()
			groups.erase(group_id)


func remove_group(group_id: int) -> void:
	if not groups.has(group_id):
		return
	
	var item: TreeItem = groups[group_id]
	item.free()
	groups.erase(group_id)


func remove_tags(from_group: int, tags: Array) -> void:
	if tags.is_empty():
		return
	
	var target: TreeItem = groups.get(from_group)
	if target == null:
		return
	
	var items: Dictionary[String, TreeItem] = {}
	for item in target.get_children():
		items[item.get_text(0)] = item
	
	for tag in tags:
		if items.has(tag):
			items[tag].free()
	
	if items.is_empty():
		target.free()
		groups.erase(from_group)


func add_data(data: Dictionary[int, Dictionary]) -> void:
	for group_id in data:
		if not groups.has(group_id):
			var new_group: TreeItem = get_root().create_child()
			new_group.set_text(0, data[group_id]["name"])
			new_group.set_metadata(0, {"is_group": true, "id": group_id})
			groups[group_id] = new_group
		
		var target: TreeItem = groups[group_id]
		var items: Dictionary[String, TreeItem] = {}
		
		for item in target.get_children():
			items[item.get_text(0)] = item
		
		var tags_dict: Dictionary = data[group_id]["tags"]
		
		for tag in tags_dict:
			if items.has(tag):
				continue
			
			var new_tag: TreeItem = target.create_child()
			new_tag.set_text(0, tag)
			new_tag.set_metadata(0, {"is_group": false, "id": tags_dict[tag]})
			items[tag] = new_tag


func get_group_data(group_id: int) -> Dictionary:
	var data: Dictionary = {}
	if not groups.has(group_id):
		return data
	
	var item: TreeItem = groups[group_id]
	var tags: Dictionary[String, int] = {}
	data["title"] = item.get_text(0)
	for tag in item.get_children():
		tags[tag.get_text(0)] = tag.get_metadata(0)["id"]
	
	data["tags"] = tags
	return data


func clear_groups() -> void:
	for group in groups:
		groups[group].free()
	groups.clear()
