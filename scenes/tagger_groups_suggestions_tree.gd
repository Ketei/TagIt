extends Tree


signal suggestions_activated(suggestion_ids: Array[int], list: Tree)
signal groups_deleted(groups: PackedInt64Array)


func _ready() -> void:
	create_item()
	item_activated.connect(on_item_activated)
	focus_exited.connect(on_focus_lost)


func _input(_event: InputEvent) -> void:
	if has_focus() and Input.is_action_just_pressed(&"ui_text_delete"):
		var selected_groups: Array[TreeItem] = get_selected_tree_groups()
		if not selected_groups.is_empty():
			var deleted_groups: PackedInt64Array = []
			for grp in selected_groups:
				if not deleted_groups.has(grp.get_metadata(0)["id"]):
					deleted_groups.append(grp.get_metadata(0)["id"])
				grp.free()
			groups_deleted.emit(deleted_groups)
			get_viewport().set_input_as_handled()


func _get_drag_data(_at_position: Vector2) -> Variant:
	var tag_array := get_selected_names()
	var tags_label := Label.new()
	var tag_count: int = tag_array.size()
	tags_label.text = str("    ", tag_count, " tag")
	if 1 != tag_count:
		tags_label.text += "s"
	set_drag_preview(tags_label)
	return {
		"type": "tag_array",
		#"tag_ids": get_selected_ids(),
		"tag_names": tag_array,
		"tree_type": 1,
		"tree": self}


func on_focus_lost() -> void:
	deselect_all()


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
	var new_group: TreeItem = get_root().create_child()
	new_group.set_text(0, Strings.title_case(suggestion_title))
	new_group.set_selectable(0, true)
	new_group.set_metadata(0, {"is_group": true, "id": group_id})
	
	for id in suggestions:
		var new_member: TreeItem = create_item(new_group)
		new_member.set_text(0, suggestions[id])
		new_member.set_metadata(0, {"is_group": false, "id": id})
	
	new_group.collapsed = true


func has_tag_group(group_id: int) -> bool:
	for group in get_root().get_children():
		if group.get_metadata(0)["id"] == group_id:
			return true
	return false


func on_item_activated() -> void:
	suggestions_activated.emit(get_selected_names(), self)


func delete_tags(tags: Array[String]) -> void:
	for tag in tags:
		for child in get_root().get_children():
			if child.get_text(0) == tag:
				child.free()
				break


func get_all_groups() -> Array[int]:
	var all_tags: Array[int] = []
	for tag in get_root().get_children():
		all_tags.append(tag.get_metadata(0)["id"])
	return all_tags


func delete_selected() -> void:
	var current: TreeItem = get_next_selected(null)
	while current != null:
		var next = get_next_selected(current)
		current.free()
		current = next
