extends Tree


signal suggestions_activated(suggestion_ids: Array[int], tree: Tree)
signal suggestions_deleted(suggestions: Array[String])


func _ready() -> void:
	create_item()
	item_activated.connect(on_item_activated)
	focus_exited.connect(on_focus_lost)


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
		"tag_names": tag_array,
		"is_group": false,
		"tree": self}


func _input(_event: InputEvent) -> void:
	if has_focus() and Input.is_action_just_pressed(&"ui_text_delete") and get_next_selected(null) != null:
		var removed: Array[String] = []
		var current: TreeItem = get_next_selected(null)
		while current != null:
			var next = get_next_selected(current)
			removed.append(current.get_text(0))
			current.free()
			current = next
		suggestions_deleted.emit(removed)
		get_viewport().set_input_as_handled()


func on_focus_lost() -> void:
	deselect_all()


func add_suggestion(suggestion_name: String) -> void:
	var new_suggestion: TreeItem = get_root().create_child()#create_item(root_tree)
	new_suggestion.set_text(0, suggestion_name)
	#new_suggestion.set_metadata(0, suggestion_id)


#func has_suggestion_id(suggestion_id: int) -> bool:
	#for child in get_root().get_children():
		#if child.get_metadata(0) == suggestion_id:
			#return true
	#return false


func has_suggestion(suggestion_text: String) -> bool:
	for child in get_root().get_children():
		if child.get_text(0) == suggestion_text:
			return true
	return false


func get_selected_names() -> Array[String]:
	var selected_ids: Array[String] = []
	var current: TreeItem = get_next_selected(null)
	while current != null:
		selected_ids.append(current.get_text(0))
		current = get_next_selected(current)
	return selected_ids


func on_item_activated() -> void:
	suggestions_activated.emit(get_selected_names(), self)
	delete_selected()


func delete_tags(tags: Array[String]) -> void:
	for tag in tags:
		for child in get_root().get_children():
			if child.get_text(0) == tag:
				child.free()
				break


func delete_tag(tag: String) -> void:
	for child in get_root().get_children():
		if child.get_text(0) == tag:
			child.free()
			break



func get_all_suggestions_text() -> Array[String]:
	var all_tags: Array[String] = []
	for tag in get_root().get_children():
		all_tags.append(tag.get_text(0))
	return all_tags


func delete_selected() -> void:
	var current: TreeItem = get_next_selected(null)
	while current != null:
		var next = get_next_selected(current)
		current.free()
		current = next
