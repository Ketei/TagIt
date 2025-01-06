extends VBoxContainer


const NEW_ALIAS_CONFIRM_DIALOG = preload("res://scenes/dialogs/new_alias_confirm_dialog.tscn")
const TOOL_ID: String = "aliaser"

#var results_keys: Array[String] = []
var alias_results: Array[Dictionary] = []
var tool_description: String = "Review, create and remove aliases."
var requires_save: bool = false

@onready var aliases_tree: Tree = $AliasesTree
@onready var search_alias_ln_edt: LineEdit = $ButtonsContainer/InteractContainer/SearchAliasLnEdt
@onready var page_spin_box: SpinBox = $PagesMargin/PageContainer/PageSpinBox
@onready var page_label: Label = $PagesMargin/PageContainer/PageLabel
@onready var new_alias_btn: Button = $ButtonsContainer/InteractContainer/NewAliasBtn
@onready var prev_page_btn: Button = $PagesMargin/PageContainer/PrevPageBtn
@onready var next_page_btn: Button = $PagesMargin/PageContainer/NextPageBtn


func _ready() -> void:
	set_prev_button_disabled(true)
	set_next_button_disabled(true)
	prev_page_btn.pressed.connect(on_page_button_pressed.bind(-1))
	next_page_btn.pressed.connect(on_page_button_pressed.bind(1))
	search_alias_ln_edt.text_submitted.connect(on_alias_searched)
	page_spin_box.value_changed.connect(on_page_changed)
	new_alias_btn.pressed.connect(on_create_alias_pressed)


func on_alias_searched(search_text: String) -> void:
	var clean_text: String = search_text.strip_edges().to_lower()
	aliases_tree.clear_aliases()
	alias_results.clear()
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
	
	while clean_text.ends_with(TagIt.SEARCH_WILDCARD):
		clean_text = clean_text.trim_suffix(TagIt.SEARCH_WILDCARD).strip_edges(false, true)
	while clean_text.begins_with(TagIt.SEARCH_WILDCARD):
		clean_text = clean_text.trim_prefix(TagIt.SEARCH_WILDCARD).strip_edges(true, false)
	
	var results: Dictionary = {}
	
	match search_mode:
		-1:# Show all
			results = TagIt.get_all_alias_names()
		0: # Exact
			if TagIt.has_tag(search_text):
				results = TagIt.search_alias(TagIt.get_tag_id(clean_text))
		1: # Ends with
			var id_array: Array[int] = []
			for tag in TagIt.loaded_tags:
				if tag.ends_with(clean_text):
					id_array.append(TagIt.loaded_tags[tag])
			results = TagIt.search_aliases(id_array)	
			#results_keys = results.keys()
		2: # Begins with
			var id_array: Array[int] = []
			for tag in TagIt.loaded_tags:
				if tag.begins_with(clean_text):
					id_array.append(TagIt.loaded_tags[tag])
			results = TagIt.search_aliases(id_array)
		3: # Contains
			var id_array: Array[int] = []
			for tag in TagIt.loaded_tags:
				if tag.containsn(clean_text):
					id_array.append(TagIt.loaded_tags[tag])
			results = TagIt.search_aliases(id_array)
	
	for consequent in results:
		for antecedent in results[consequent]:
			alias_results.append({"antecedent": antecedent, "consequent": consequent})
			
	
	#results_keys = Array(results.keys(), TYPE_STRING, &"", null)
	var slice := alias_results.slice(0, TagIt.settings.results_per_search)
	
	page_spin_box.max_value = maxf(1, ceilf(alias_results.size() / float(TagIt.settings.results_per_search)))
	page_label.text = "/ " + str(int(page_spin_box.max_value))
	
	for alias_dict in slice:
		aliases_tree.add_alias(alias_dict["antecedent"], alias_dict["consequent"])
	
	set_prev_button_disabled(true)
	set_next_button_disabled(page_spin_box.max_value <= 1)


func on_page_button_pressed(page_change: int) -> void:
	page_spin_box.value += page_change


func set_next_button_disabled(set_disabled: bool) -> void:
	next_page_btn.disabled = set_disabled
	next_page_btn.focus_mode = Control.FOCUS_NONE if set_disabled else Control.FOCUS_ALL


func set_prev_button_disabled(set_disabled: bool) -> void:
	prev_page_btn.disabled = set_disabled
	prev_page_btn.focus_mode = Control.FOCUS_NONE if set_disabled else Control.FOCUS_ALL


func on_page_changed(new_page: float) -> void:
	@warning_ignore("narrowing_conversion")
	var slice := alias_results.slice(
			TagIt.settings.results_per_search * (new_page - 1),
			TagIt.settings.results_per_search * new_page)
	
	aliases_tree.clear_aliases()
	
	for alias_dict in slice:
		aliases_tree.add_alias(alias_dict["antecedent"], alias_dict["consequent"])
	
	set_prev_button_disabled(page_spin_box.value == 1)
	set_next_button_disabled(page_spin_box.max_value <= page_spin_box.value)


func on_create_alias_pressed() -> void:
	var new_alias_dialog := NEW_ALIAS_CONFIRM_DIALOG.instantiate()
	add_child(new_alias_dialog)
	new_alias_dialog.show()
	var result: Array = await new_alias_dialog.dialog_finished
	if result[0] and not TagIt.is_name_aliased(result[1], result[2]):
		TagIt.add_alias(result[1], result[2])
	new_alias_dialog.queue_free()
