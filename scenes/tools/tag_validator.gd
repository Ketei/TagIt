extends HBoxContainer


signal something_changed

const TOOL_ID: String = "validator"
var tool_description: String = "Create or change if a tag is invalid."
var tag_results: Array[int] = []
var requires_save: bool = true

var unsaved_changes: bool = false

@onready var validator_tree: Tree = $TreeContainer/ValidatorTree
@onready var search_ln_edt: LineEdit = $TreeContainer/SearchContainer/InvalidSearchLnEdt
@onready var create_valid_tree: Tree = $CreatorContainer/CreateValidTree
@onready var create_valid_ln_edt: LineEdit = $CreatorContainer/HBoxContainer/CreateValidLnEdt
@onready var page_spinbox: SpinBox = $TreeContainer/HBoxContainer/PageSpinbox
@onready var max_page_label: Label = $TreeContainer/HBoxContainer/MaxPageLabel
@onready var clear_button: Button = $CreatorContainer/PanelContainer/HBoxContainer/ClearButton
@onready var import_button: Button = $CreatorContainer/PanelContainer/HBoxContainer/ImportButton


func _ready() -> void:
	search_ln_edt.text_submitted.connect(on_tag_searched)
	create_valid_ln_edt.text_submitted.connect(on_tag_creation_submitted)
	page_spinbox.value_changed.connect(on_tag_page_changed)
	clear_button.pressed.connect(_on_clear_pressed)
	import_button.pressed.connect(_on_add_from_text_pressed)


func _on_add_from_text_pressed() -> void:
	var new_window := preload("res://scenes/dialogs/tag_reader_dialog.tscn").instantiate()
	add_child(new_window)
	new_window.show()
	
	var new_tags: PackedStringArray = await new_window.tags_finished
	
	if not new_tags.is_empty():
		var existing: Array[String] = []
		
		for tag in new_tags:
			if SingletonManager.TagIt.has_tag(tag):
				existing.append(tag)
			else:
				if not create_valid_tree.has_tag(tag):
					create_valid_tree.add_tag(tag)
		
		if not existing.is_empty():
			validator_tree.clear_tags()
			for tag in existing:
				validator_tree.add_tag(
					SingletonManager.TagIt.get_tag_id(tag),
					tag,
					SingletonManager.TagIt.is_tag_valid(
							SingletonManager.TagIt.get_tag_id(tag)))
	
	new_window.queue_free()


func _on_clear_pressed() -> void:
	create_valid_tree.clear_tags()


func on_tag_creation_submitted(add_text: String) -> void:
	var clean_text: String = add_text.strip_edges().to_lower()
	create_valid_ln_edt.clear()
	
	if clean_text.is_empty() or create_valid_tree.has_tag(clean_text):
		return
	
	if SingletonManager.TagIt.has_tag(clean_text):
		page_spinbox.value = 1
		validator_tree.clear_tags()
		tag_results = [SingletonManager.TagIt.get_tag_id(clean_text)]
		validator_tree.set_tags(tag_results)
		return
	
	create_valid_tree.add_tag(clean_text)


func field_edited() -> void:
	if not unsaved_changes:
		unsaved_changes = true
		something_changed.emit()


func on_tag_searched(search_text: String) -> void:
	var clean_text: String = search_text.strip_edges().to_lower()
	
	page_spinbox.value = 1
	validator_tree.clear_tags()
	tag_results.clear()
	
	if clean_text.is_empty():
		return
	
	var search_mode: int = 0
	
	if clean_text == DataManager.SEARCH_WILDCARD:
		search_mode = 4
	else:
		if clean_text.begins_with(DataManager.SEARCH_WILDCARD):
			search_mode += 2
			clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD)
		
		if clean_text.ends_with(DataManager.SEARCH_WILDCARD):
			search_mode += 1
			clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD)
	
	match search_mode:
		2: # Ends with
			var tags := SingletonManager.TagIt.get_all_tag_names(false)
			for tag in tags:
				if tag.ends_with(clean_text):
					tag_results.append(SingletonManager.TagIt.get_tag_id(tag))
		3: # Contains
			var tags := SingletonManager.TagIt.get_all_tag_names(false)
			for tag in tags:
				if tag.contains(clean_text):
					tag_results.append(SingletonManager.TagIt.get_tag_id(tag))
		4:# Show all
			tag_results = SingletonManager.TagIt.get_all_ids()
		_: # Beggins With
			var tags := SingletonManager.TagIt.get_all_tag_names(false)
			for tag in tags:
				if tag.begins_with(clean_text):
					tag_results.append(SingletonManager.TagIt.get_tag_id(tag))
	
	var slice: Array[int] = tag_results.slice(0, SingletonManager.TagIt.settings.results_per_search)
	page_spinbox.max_value = maxi(1, ceili(tag_results.size() / float(SingletonManager.TagIt.settings.results_per_search)))
	max_page_label.text = "/ " + str(page_spinbox.max_value)
	
	validator_tree.set_tags(slice)


func on_tag_page_changed(new_page: float) -> void:
	validator_tree.clear_tags()
	var from: int = int(new_page - 1) * SingletonManager.TagIt.settings.results_per_search
	var to: int = SingletonManager.TagIt.settings.results_per_search * int(new_page)
	var slice: Array[int] = tag_results.slice(from, to)
	validator_tree.set_tags(slice)


func on_save_pressed() -> void:
	var valid_tags: Array[int] = validator_tree.get_tags_edited(true)
	var invalid_tags: Array[int] = validator_tree.get_tags_edited(false)
	var new_tags_invalid: Array[String] = create_valid_tree.get_new_invalid_tags()
	
	if not valid_tags.is_empty():
		SingletonManager.TagIt.set_tags_valid(valid_tags, true)
	if not invalid_tags.is_empty():
		SingletonManager.TagIt.set_tags_valid(invalid_tags, false)
	if not new_tags_invalid.is_empty():
		SingletonManager.TagIt.create_empty_tags(new_tags_invalid, false)
	
	validator_tree.clear_edited_tags()
	create_valid_tree.clear_tags()
	
	if unsaved_changes:
		unsaved_changes = false
