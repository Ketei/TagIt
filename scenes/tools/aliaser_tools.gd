extends VBoxContainer


const NEW_ALIAS_CONFIRM_DIALOG = preload("res://scenes/dialogs/new_alias_confirm_dialog.tscn")
const TOOL_ID: String = "aliaser"

var results_keys: Array[String] = []
var results: Dictionary = {}
var tool_description: String = "Review, create and remove aliases."
var requires_save: bool = false

@onready var aliases_tree: Tree = $AliasesTree
@onready var search_alias_ln_edt: LineEdit = $ButtonsContainer/InteractContainer/SearchAliasLnEdt
@onready var page_spin_box: SpinBox = $PagesMargin/PageContainer/PageSpinBox
@onready var page_label: Label = $PagesMargin/PageContainer/PageLabel
@onready var new_alias_btn: Button = $ButtonsContainer/InteractContainer/NewAliasBtn


func _ready() -> void:
	search_alias_ln_edt.text_submitted.connect(on_alias_searched)
	page_spin_box.value_changed.connect(on_page_changed)
	new_alias_btn.pressed.connect(on_create_alias_pressed)


func on_alias_searched(search_text: String) -> void:
	var clean_text: String = search_text.strip_edges().to_lower()
	aliases_tree.clear_aliases()
	results.clear()
	results_keys.clear()
	page_spin_box.value = 1
	
	if clean_text.is_empty():
		return
	
	var search_mode: int = 0
	
	if clean_text == TagIt.SEARCH_WILDCARD:
		search_mode = -1
	else:
		if clean_text.begins_with(TagIt.SEARCH_WILDCARD):
			search_mode += 1
			clean_text = clean_text.trim_prefix(TagIt.SEARCH_WILDCARD)
		
		if clean_text.ends_with(TagIt.SEARCH_WILDCARD):
			search_mode += 2
			clean_text = clean_text.trim_suffix(TagIt.SEARCH_WILDCARD)
	
	match search_mode:
		-1:# Show all
			results = TagIt.get_all_alias_names()
			#results_keys = Array(results.keys(), TYPE_STRING, &"", null)
		0: # Exact
			if TagIt.has_tag(search_text):
				results = TagIt.search_alias(TagIt.get_tag_id(search_text))
				#results_keys = Array(results.keys(), TYPE_STRING, &"", null)
		1: # Ends with
			var id_array: Array[int] = []
			for tag in TagIt.get_all_tag_ids(true):
				if TagIt.get_tag_name(tag).ends_with(search_text):
					id_array.append(tag)
			results = TagIt.search_aliases(id_array)	
			#results_keys = results.keys()
		2: # Begins with
			var id_array: Array[int] = []
			for tag in TagIt.get_all_tag_ids(true):
				if TagIt.get_tag_name(tag).begins_with(search_text):
					id_array.append(tag)
			results = TagIt.search_aliases(id_array)
		3: # Contains
			var id_array: Array[int] = []
			for tag in TagIt.get_all_tag_ids(true):
				if TagIt.get_tag_name(tag).contains(search_text):
					id_array.append(tag)
			results = TagIt.search_aliases(id_array)
	
	results_keys = Array(results.keys(), TYPE_STRING, &"", null)
	var slice := results_keys.slice(0, TagIt.settings.results_per_search)
	@warning_ignore("integer_division")
	page_spin_box.max_value = maxf(1, ceilf(slice.size() / TagIt.settings.results_per_search))
	page_label.text = "/ " + str(int(page_spin_box.max_value))
	for aliased_to in slice:
		for aliased_from in results[aliased_to]:
			aliases_tree.add_alias(aliased_from, aliased_to)


func on_page_changed(new_page: float) -> void:
	@warning_ignore("narrowing_conversion")
	var slice := results_keys.slice(
			TagIt.settings.results_per_search * (new_page - 1),
			TagIt.settings.results_per_search * new_page)
	for aliased_to in slice:
		for aliased_from in results[aliased_to]:
			aliases_tree.add_alias(aliased_from, aliased_to)


func on_create_alias_pressed() -> void:
	var new_alias_dialog := NEW_ALIAS_CONFIRM_DIALOG.instantiate()
	add_child(new_alias_dialog)
	new_alias_dialog.show()
	var result: Array = await new_alias_dialog.dialog_finished
	if result[0] and not TagIt.is_name_aliased(result[1], result[2]):
		TagIt.add_alias(result[1], result[2])
	new_alias_dialog.queue_free()
