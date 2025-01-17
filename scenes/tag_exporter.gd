extends PanelContainer


signal export_tags_pressed(tag_ids: Array[int])
signal export_tags_cancelled

const STEP: int = 10
var all_valid_tags: Array[String] = []
var selected_ids: Array[int] = [] # contains index of all_valid_tags
var value: int = 0 # Current page
var search_results: Array[Dictionary] = []
var _using_search: bool = false

@onready var tags_tree: Tree = $MainCenter/AllTags/MarginContainer/MainContainer/TagsTree
@onready var prev_button: Button = $MainCenter/AllTags/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/LeftButton
@onready var next_button: Button = $MainCenter/AllTags/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/NextButton
@onready var current_lbl: Label = $MainCenter/AllTags/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/PageContainer/CurrentLbl
@onready var pages_lbl: Label = $MainCenter/AllTags/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/PageContainer/PagesLbl
@onready var serch_tag_ln_edt: LineEdit = $MainCenter/AllTags/MarginContainer/MainContainer/SearchMargin/SerchTagLnEdt

@onready var close_button: Button = $MainCenter/AllTags/MarginContainer/MainContainer/TitlePanel/CloseButton
@onready var export_button: Button = $MainCenter/AllTags/MarginContainer/MainContainer/MarginContainer/BottomPanel/ExportButton
@onready var cancel_button: Button = $MainCenter/AllTags/MarginContainer/MainContainer/MarginContainer/BottomPanel/CancelButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tags_tree.create_item()
	
	all_valid_tags = SingletonManager.TagIt.get_all_tag_names(true)
	
	var amount: int = 0
	var idx: int = -1
	for tag in all_valid_tags:
		amount += 1
		idx += 1
		add_tag(tag, idx)
		if STEP <= amount:
			break
	
	current_lbl.text = "1"
	pages_lbl.text = "/ " + str(maxi(1, ceili(all_valid_tags.size() / float(STEP))))
	set_next_arrow_disabled(all_valid_tags.size() < ((value + 1) * STEP))
	set_prev_arrow_disabled(value <= 0)
	
	tags_tree.item_edited.connect(on_tree_item_edited)
	serch_tag_ln_edt.text_submitted.connect(on_search_tag_text_submitted)
	next_button.pressed.connect(on_arrow_page_pressed.bind(1))
	prev_button.pressed.connect(on_arrow_page_pressed.bind(-1))
	close_button.pressed.connect(on_cancel_export)
	cancel_button.pressed.connect(on_cancel_export)
	export_button.pressed.connect(on_export_button_pressed)


func on_search_tag_text_submitted(text: String) -> void:
	var clean_text: String = text.strip_edges().to_lower()
	
	var as_prefix: bool = text.ends_with(DataManager.SEARCH_WILDCARD)
	var as_suffix: bool = text.begins_with(DataManager.SEARCH_WILDCARD)
	
	if as_prefix:
		clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD)
		clean_text = clean_text.strip_edges(false, true)
	if as_suffix:
		clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD)
		clean_text = clean_text.strip_edges(true, false)
	
	while clean_text.ends_with(DataManager.SEARCH_WILDCARD):
		clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD)
		clean_text = clean_text.strip_edges(false, true)
	
	while clean_text.begins_with(DataManager.SEARCH_WILDCARD):
		clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD)
		clean_text = clean_text.strip_edges(true, false)
	
	clear_tags()
	search_results.clear()
	value = 0
	
	if clean_text.is_empty():
		var amount: int = 0
		var idx: int = -1
		for tag in all_valid_tags:
			amount += 1
			idx += 1
			add_tag(tag, idx)
			if STEP <= amount:
				break
		_using_search = false
		set_prev_arrow_disabled(value <= 0)
		set_next_arrow_disabled(all_valid_tags.size() < ((value + 1) * STEP))
		pages_lbl.text = "/ " + str(maxi(1, ceili(all_valid_tags.size() / float(STEP))))
	else:
		if as_prefix and as_suffix:
			for item_idx in range(all_valid_tags.size()):
				if all_valid_tags[item_idx].containsn(clean_text):
					search_results.append({"tag": all_valid_tags[item_idx], "id": item_idx})
		elif as_suffix:
			for item_idx in range(all_valid_tags.size()):
				if all_valid_tags[item_idx].ends_with(clean_text):
					search_results.append({"tag": all_valid_tags[item_idx], "id": item_idx})
		else:
			for item_idx in range(all_valid_tags.size()):
				if all_valid_tags[item_idx].begins_with(clean_text):
					search_results.append({"tag": all_valid_tags[item_idx], "id": item_idx})
		
		var amount: int = 0
		
		for search_result in search_results:
			amount += 1
			add_tag(search_result["tag"], search_result["id"])
			if STEP <= amount:
				break
		
		current_lbl.text = "1"
		
		_using_search = true
		set_prev_arrow_disabled(value <= 0)
		
		if _using_search:
			pages_lbl.text = "/ " + str(maxi(1, ceili(search_results.size() / float(STEP))))
			set_next_arrow_disabled(search_results.size() < ((value + 1) * STEP))
		else:
			pages_lbl.text = "/ " + str(maxi(1, ceili(all_valid_tags.size() / float(STEP))))
			set_next_arrow_disabled(all_valid_tags.size() < ((value + 1) * STEP))
			
		


func add_tag(tag_string: String, tag_idx: int) -> void:
	var tag_item: TreeItem = tags_tree.get_root().create_child()
	tag_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	tag_item.set_text(0, tag_string)
	tag_item.set_metadata(0, tag_idx)
	tag_item.set_editable(0, true)


func on_arrow_page_pressed(sum_val: int) -> void:
	value += sum_val
	current_lbl.text = str(value + 1)
	set_prev_arrow_disabled(value <= 0)
	
	if _using_search:
		set_next_arrow_disabled(search_results.size() < ((value + 1) * STEP))
	else:
		set_next_arrow_disabled(all_valid_tags.size() < ((value + 1) * STEP))
	
	clear_tags()
	
	var sub_idx: int = -1
	
	if _using_search:
		var sub_array: Array[Dictionary] = search_results.slice(value * STEP, (value + 1) * STEP)
		for tag in sub_array:
			sub_idx += 1
			add_tag(tag["tag"], tag["id"])
	else:
		var sub_array: PackedStringArray = all_valid_tags.slice(value * STEP, (value + 1) * STEP)
		for tag in sub_array:
			sub_idx += 1
			add_tag(tag, (value * STEP) + sub_idx)


func on_tree_item_edited() -> void:
	var edited: TreeItem = tags_tree.get_edited()
	if edited.is_checked(0):
		Arrays.insert_sorted_asc(selected_ids, edited.get_metadata(0))
	else:
		selected_ids.remove_at(Arrays.binary_search(selected_ids, edited.get_metadata(0)))


func clear_tags() -> void:
	for tag in tags_tree.get_root().get_children():
		tag.free()


func set_prev_arrow_disabled(set_disabled: bool) -> void:
	prev_button.disabled = set_disabled
	prev_button.focus_mode = Control.FOCUS_ALL if not set_disabled else Control.FOCUS_NONE


func set_next_arrow_disabled(set_disabled: bool) -> void:
	next_button.disabled = set_disabled
	next_button.focus_mode = Control.FOCUS_ALL if not set_disabled else Control.FOCUS_NONE


func on_export_button_pressed() -> void:
	var exported_tags: Array[int] = []
	for tag_idx in selected_ids:
		exported_tags.append(SingletonManager.TagIt.get_tag_id(all_valid_tags[tag_idx]))
	export_tags_pressed.emit(exported_tags)


func on_cancel_export() -> void:
	export_tags_cancelled.emit()
