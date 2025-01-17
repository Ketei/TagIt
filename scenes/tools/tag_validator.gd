extends HBoxContainer


const TOOL_ID: String = "validator"
var tool_description: String = "Create or change if a tag is invalid."
var tag_results: Array[int] = []
var requires_save: bool = true

@onready var validator_tree: Tree = $TreeContainer/ValidatorTree
@onready var search_ln_edt: LineEdit = $TreeContainer/SearchContainer/InvalidSearchLnEdt
@onready var create_valid_tree: Tree = $CreatorContainer/CreateValidTree
@onready var create_valid_ln_edt: LineEdit = $CreatorContainer/HBoxContainer/CreateValidLnEdt
@onready var page_spinbox: SpinBox = $TreeContainer/HBoxContainer/PageSpinbox
@onready var max_page_label: Label = $TreeContainer/HBoxContainer/MaxPageLabel


func _ready() -> void:
	search_ln_edt.text_submitted.connect(on_tag_searched)
	create_valid_ln_edt.text_submitted.connect(on_tag_creation_submitted)
	page_spinbox.value_changed.connect(on_tag_page_changed)


func on_tag_creation_submitted(add_text: String) -> void:
	var clean_text: String = add_text.strip_edges().to_lower()
	create_valid_ln_edt.clear()
	
	if clean_text.is_empty() or SingletonManager.TagIt.has_tag(clean_text) or create_valid_tree.has_tag(clean_text):
		return
	
	create_valid_tree.add_tag(clean_text)


func on_tag_searched(search_text: String) -> void:
	var clean_text: String = search_text.strip_edges().to_lower()
	#search_ln_edt.clear()
	page_spinbox.value = 1
	
	if clean_text.is_empty():
		return
	
	var search_mode: int = 0
	tag_results.clear()
	
	if clean_text == DataManager.SEARCH_WILDCARD:
		search_mode = -1
	else:
		if clean_text.begins_with(DataManager.SEARCH_WILDCARD):
			search_mode += 1
			clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD)
		
		if clean_text.ends_with(DataManager.SEARCH_WILDCARD):
			search_mode += 2
			clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD)
	
	match search_mode:
		-1:# Show all
			tag_results = SingletonManager.TagIt.get_all_ids()
			#validator_tree.set_tags()
		0: # Exact
			if SingletonManager.TagIt.has_tag(clean_text):
				tag_results.append(SingletonManager.TagIt.get_tag_id(clean_text))
		1: # Ends with
			var tags := SingletonManager.TagIt.get_tags(SingletonManager.TagIt.get_all_tag_ids(true))
			for tag in tags:
				if tags[tag]["name"].ends_with(clean_text):
					tag_results.append(tag)
			
			#validator_tree.set_tags(id_array)
		2: # Begins with
			var tags := SingletonManager.TagIt.get_tags(SingletonManager.TagIt.get_all_tag_ids(true))
			for tag in tags:
				if tags[tag]["name"].begins_with(clean_text):
					tag_results.append(tag)
			#validator_tree.set_tags(id_array)
		3: # Contains
			var tags := SingletonManager.TagIt.get_tags(SingletonManager.TagIt.get_all_tag_ids(true))
			for tag in tags:
				if tags[tag]["name"].contains(clean_text):
					tag_results.append(tag)
			#validator_tree.set_tags(id_array)
	
	var slice: Array[int] = tag_results.slice(0, SingletonManager.TagIt.settings.results_per_search)
	@warning_ignore("integer_division")
	page_spinbox.max_value = maxi(1, ceili(tag_results.size() / SingletonManager.TagIt.settings.results_per_search))
	max_page_label.text = "/ " + str(page_spinbox.max_value)
	
	validator_tree.set_tags(slice)


func on_tag_page_changed(new_page: float) -> void:
	@warning_ignore("narrowing_conversion")
	var slice: Array[int] = tag_results.slice(0, SingletonManager.TagIt.settings.results_per_search * new_page)
	validator_tree.set_tags(slice)


func on_save_pressed() -> void:
	var valid_tags: Array[int] = validator_tree.get_tags_edited(true)
	var invalid_tags: Array[int] = validator_tree.get_tags_edited(false)
	var new_tags_invalid: Array[String] = create_valid_tree.get_new_invalid_tags()
	
	SingletonManager.TagIt.set_tags_valid(valid_tags, true)
	SingletonManager.TagIt.set_tags_valid(invalid_tags, false)
	
	SingletonManager.TagIt.create_empty_tags(new_tags_invalid, false)
	
	validator_tree.clear_edited_tags()
	validator_tree.clear_tags()
	create_valid_tree.clear_tags()
