extends Control


signal close_pressed

var priority_tags: Dictionary = {} : set = set_priority_tags

@onready var prio_tree: Tree = $MainDraggable/MainPanel/MainMargin/MainContainer/PrioTree
@onready var close_window_btn: Button = $MainDraggable/MainPanel/MainMargin/MainContainer/Label/CloseWindowBtn
@onready var add_tag_ln_edt: LineEdit = $MainDraggable/MainPanel/MainMargin/MainContainer/AddTagLnEdt


func _ready() -> void:
	prio_tree.create_item()
	
	prio_tree.set_column_title(0, "Tag")
	prio_tree.set_column_title(1, "Priority")
	
	prio_tree.set_column_expand(0, true)
	prio_tree.set_column_expand(1, true)
	
	prio_tree.set_column_expand_ratio(0, 5)
	prio_tree.set_column_expand_ratio(1, 1)
	
	add_tag_ln_edt.text_submitted.connect(_on_text_submitted)
	add_tag_ln_edt.timer_finished.connect(on_search_timer_timeout)
	prio_tree.item_edited.connect(_on_item_edited)
	close_window_btn.pressed.connect(_on_close_button_pressed)
	prio_tree.tags_dropped.connect(_on_tags_dropped)


func _on_tags_dropped(tags: Array[String]) -> void:
	for tag in tags:
		_on_text_submitted(tag)


func _input(_event: InputEvent) -> void:
	if prio_tree.has_focus():
		if Input.is_action_just_pressed(&"ui_text_delete"):
			var current: TreeItem = prio_tree.get_next_selected(null)
			while current != null:
				var next: TreeItem = prio_tree.get_next_selected(current)
				current.free()
				current = next
			get_viewport().set_input_as_handled()


func _on_text_submitted(new_text: String) -> void:
	var clean_text: String = new_text.strip_edges().to_lower()
	add_tag_ln_edt.clear()
	
	if clean_text.is_empty() or has_tag(clean_text):
		return
	
	var prio: int = 0
	
	if SingletonManager.TagIt.has_tag(clean_text):
		var tag_id: int = SingletonManager.TagIt.get_tag_id(clean_text)
		if SingletonManager.TagIt.has_alias(tag_id):
			clean_text = SingletonManager.TagIt.get_alias_name(clean_text)
		
	if SingletonManager.TagIt.has_tag(clean_text):
		var tag_id: int = SingletonManager.TagIt.get_tag_id(clean_text)
		if SingletonManager.TagIt.has_data(tag_id):
			prio = SingletonManager.TagIt.get_tag_data_column(
					SingletonManager.TagIt.get_tag_id(clean_text),
					"priority")
	
	add_tag(clean_text, prio)
	priority_tags[clean_text] = prio


func _on_close_button_pressed() -> void:
	close_pressed.emit()


func _on_item_edited() -> void:
	var edited: TreeItem = prio_tree.get_edited()
	priority_tags[edited.get_text(0)] = int(edited.get_range(1))


func clear_tags() -> void:
	for tag in prio_tree.get_root().get_children():
		tag.free()


func on_search_timer_timeout() -> void:
	if not add_tag_ln_edt.has_focus():
		return
	
	add_tag_ln_edt.clear_list()
	var clean_text: String = add_tag_ln_edt.text.strip_edges().to_lower()
	var prefix: bool = clean_text.ends_with(DataManager.SEARCH_WILDCARD)
	var suffix: bool = clean_text.begins_with(DataManager.SEARCH_WILDCARD)
	
	if prefix:
		clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD).strip_edges(true, false)
	if suffix:
		clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD).strip_edges(false, true)
	
	while clean_text.begins_with(DataManager.SEARCH_WILDCARD):
		clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD).strip_edges(true, false)
	
	while clean_text.ends_with(DataManager.SEARCH_WILDCARD):
		clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD).strip_edges(false, true)
	
	if clean_text.is_empty():
		return
	
	var results: PackedStringArray = []
	
	if prefix and suffix:
		results = SingletonManager.TagIt.search_for_tag_contains(clean_text, add_tag_ln_edt.item_limit, true)
	elif suffix:
		results = SingletonManager.TagIt.search_for_tag_suffix(clean_text, add_tag_ln_edt.item_limit, true)
	else:
		results = SingletonManager.TagIt.search_for_tag_prefix(clean_text, add_tag_ln_edt.item_limit, true)
	
	var id_results: Array[int] = Array(SingletonManager.TagIt.get_tags_ids(results).values(), TYPE_INT, &"", null)
	
	var tags_with_aliases: Dictionary = SingletonManager.TagIt.get_aliases_consequent_names_from(id_results)
	
	if not results.is_empty():
		for tag in results:
			if tags_with_aliases.has(SingletonManager.TagIt.get_tag_id(tag)):
				add_tag_ln_edt.add_item(
						tag,
						tags_with_aliases[SingletonManager.TagIt.get_tag_id(tag)])
			else:
				add_tag_ln_edt.add_item(tag)
		
		add_tag_ln_edt.show_items()


func add_tag(tag_id: String, tag_priority: int = 0) -> void:
	var new_tag: TreeItem = prio_tree.get_root().create_child()
	new_tag.set_text(0, tag_id)
	
	new_tag.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	new_tag.set_range_config(1, -9999, 9999, 1.0)
	new_tag.set_range(1, tag_priority)
	
	new_tag.set_editable(0, false)
	new_tag.set_editable(1, true)


func has_tag(tag_id: String) -> bool:
	for tag in prio_tree.get_root().get_children():
		if Strings.nocasecmp_equal(tag.get_text(0), tag_id):
			return true
	return false


func set_priority_tags(new_tags: Dictionary) -> void:
	clear_tags()
	
	priority_tags = new_tags
	
	for tag in new_tags:
		add_tag(tag, new_tags[tag])
