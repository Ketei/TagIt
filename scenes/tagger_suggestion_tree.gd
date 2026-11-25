extends Tree


signal suggestions_activated(suggestion_ids: Array[String])
signal suggestions_deleted(suggestions: Array[String])

var _suggestions: Dictionary[String, TreeItem] = {}


func _ready() -> void:
	create_item()
	item_activated.connect(on_item_activated)
	focus_exited.connect(on_focus_lost)


func _get_drag_data(_at_position: Vector2) -> Variant:
	var tag_array: Array[String] = get_selected_names()
	var tags_label := Label.new()
	var tag_count: int = tag_array.size()
	tags_label.text = str("    ", tag_count, " tag")
	if 1 != tag_count:
		tags_label.text += "s"
	set_drag_preview(tags_label)
	return {
		"type": "suggestions",
		"tag_names": tag_array,
		"tree_type": 0}


func _input(event: InputEvent) -> void:
	if has_focus() and event is InputEventKey and not event.is_echo():
		if Input.is_action_just_pressed(&"ui_text_delete") and get_next_selected(null) != null:
			var removed: Array[String] = []
			var current: TreeItem = get_next_selected(null)
			while current != null:
				var next = get_next_selected(current)
				removed.append(current.get_text(0))
				current = next
			suggestions_deleted.emit(removed)
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_A and event.ctrl_pressed and event.pressed:
			for sugg in get_root().get_children():
				sugg.select(0)
			get_viewport().set_input_as_handled()


func on_focus_lost() -> void:
	deselect_all()


func add_suggestion(text: String) -> bool:
	if _suggestions.has(text):
		return false
	
	var new_suggestion: TreeItem = get_root().create_child()
	new_suggestion.set_text(0, text)
	_suggestions[text] = new_suggestion
	return true


func has_suggestion(suggestion_text: String) -> bool:
	return _suggestions.has(suggestion_text)


func get_selected_names() -> Array[String]:
	var selected_ids: Array[String] = []
	var current: TreeItem = get_next_selected(null)
	while current != null:
		selected_ids.append(current.get_text(0))
		current = get_next_selected(current)
	return selected_ids


func on_item_activated() -> void:
	suggestions_activated.emit(get_selected_names())


func delete_tags(tags: Array[String]) -> void:
	for tag in tags:
		if _suggestions.has(tag):
			_suggestions[tag].free()
			_suggestions.erase(tag)


func delete_tag(tag: String) -> void:
	if _suggestions.has(tag):
		_suggestions[tag].free()
		_suggestions.erase(tag)


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


func clear_suggestions() -> void:
	for item in _suggestions:
		_suggestions[item].free()
	_suggestions.clear()
