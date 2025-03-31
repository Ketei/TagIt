extends Control


signal tags_selected(tags: PackedStringArray)
signal panel_close_pressed

@export var step: int = 10

var value = 0:
	set(new_page):
		value = new_page
		current_lbl.text = str(value + 1)
var _current_search: String = ""
var current_tags: PackedStringArray = []
var active_tags: PackedStringArray = []
var _api_working: bool = false

@onready var close_button: Button = $DraggableContainer/MainControl/MarginContainer/MainContainer/TitlePanel/CloseButton
@onready var tags_tree: Tree = $DraggableContainer/MainControl/MarginContainer/MainContainer/TagsTree
@onready var search_tag_ln_edt: LineEdit = $DraggableContainer/MainControl/MarginContainer/MainContainer/SearchMargin/SerchTagLnEdt
@onready var prev_button: Button = $DraggableContainer/MainControl/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/LeftButton
@onready var current_lbl: Label = $DraggableContainer/MainControl/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/PageContainer/CurrentLbl
@onready var pages_lbl: Label = $DraggableContainer/MainControl/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/PageContainer/PagesLbl
@onready var next_button: Button = $DraggableContainer/MainControl/MarginContainer/MainContainer/MarginContainer/BottomPanel/HBoxContainer/NextButton
@onready var add_button: Button = $DraggableContainer/MainControl/MarginContainer/MainContainer/MarginContainer/BottomPanel/AddButton
@onready var search_cooldown: Timer = $SearchCooldown
@onready var esix_cooldown_bar: TextureProgressBar = $DraggableContainer/MainControl/MarginContainer/MainContainer/MarginContainer/BottomPanel/eSixCooldownBar


func _ready() -> void:
	tags_tree.create_item()
	search_tag_ln_edt.text_submitted.connect(on_search_text_submitted)
	next_button.pressed.connect(on_arrow_page_pressed.bind(1))
	prev_button.pressed.connect(on_arrow_page_pressed.bind(-1))
	add_button.pressed.connect(on_add_selected_pressed)
	search_cooldown.timeout.connect(on_cooldown_finished)
	SingletonManager.eSixAPI.tag_search_results_found.connect(on_api_tag_responded)
	close_button.pressed.connect(panel_close_pressed.emit)
	tags_tree.tags_marked.connect(on_tags_marked)
	tags_tree.item_activated.connect(on_add_selected_pressed)


func focus_main(select_all: bool = false) -> void:
	search_tag_ln_edt.grab_focus()
	search_tag_ln_edt.caret_column = search_tag_ln_edt.text.length()
	if select_all:
		search_tag_ln_edt.select_all()


func on_tags_marked(tags: Array[String]) -> void:
	Arrays.append_uniques_asc(active_tags, tags)


func on_search_text_submitted(text: String) -> void:
	var clean_text: String = text.strip_edges()
	
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
	
	current_tags.clear()
	value = 0
	_current_search = clean_text
	clear_tags()
	
	if clean_text.is_empty():
		pages_lbl.text = "/ 1"
		set_next_arrow_disabled(true)
		set_prev_arrow_disabled(true)
		return
	else:
		if as_prefix and as_suffix:
			current_tags = SingletonManager.TagIt.search_for_tag_contains(clean_text, 100)
		elif as_suffix:
			current_tags = SingletonManager.TagIt.search_for_tag_suffix(clean_text, 100)
		else:
			current_tags = SingletonManager.TagIt.search_for_tag_prefix(clean_text, 100)
	
	pages_lbl.text = "/ " + str(maxi(1, ceili(current_tags.size() / float(step))))
	
	if SingletonManager.TagIt.settings.search_tags_on_esix and not _api_working:
		esix_cooldown_bar.radial_fill_degrees = 360.0
		esix_cooldown_bar.tooltip_text = "Cooldown on the e621 API."
		var e_tag: String = ""
		if as_suffix:
			e_tag += "*"
		e_tag += clean_text + "*"
		SingletonManager.eSixAPI.search_for_tags(e_tag)
		_api_working = true
	
	on_arrow_page_pressed(0)


func on_arrow_page_pressed(sum_val: int) -> void:
	value += sum_val
	set_prev_arrow_disabled(value <= 0)
	set_next_arrow_disabled(current_tags.size() < ((value + 1) * step))
	clear_tags()
	
	var sub_array: PackedStringArray = current_tags.slice(value * step, (value + 1) * step)
	
	for tag in sub_array:
		var new_item: TreeItem = tags_tree.get_root().create_child()
		new_item.set_text(0, tag)
		if Arrays.binary_search(active_tags, tag) != -1:
			new_item.set_custom_color(0, Color.LIME_GREEN)


func has_tag(tag_text: String) -> bool:
	for tag in tags_tree.get_root().get_children():
		if tag.get_text(0) == tag_text:
			return true
	return false


func on_add_selected_pressed() -> void:
	var selected_tags: PackedStringArray = []
	var current: TreeItem = tags_tree.get_next_selected(null)
	while current != null:
		var tag_string: String = current.get_text(0)
		selected_tags.append(tag_string)
		
		if Arrays.binary_search(active_tags, tag_string) == -1:
			Arrays.insert_sorted_asc(active_tags, tag_string)
		current.set_custom_color(0, Color.LIME_GREEN)
		current = tags_tree.get_next_selected(current)
	tags_selected.emit(selected_tags)


func on_api_tag_responded(for_search: String, tags: PackedStringArray) -> void:
	search_cooldown.start()
	var tween: Tween = create_tween()
	tween.tween_callback(clear_progress_tooltip)
	tween.tween_property(esix_cooldown_bar, ^"radial_fill_degrees", 0.0, search_cooldown.wait_time)
	
	if not for_search.trim_prefix("*").trim_suffix("*") == _current_search:
		return
	
	for item in tags:
		if not current_tags.has(item):
			current_tags.append(item)
	#print(current_tags)
	
	var current_count: int = tags_tree.get_root().get_child_count()
	
	if current_count < step:
		for tag in tags:
			if has_tag(tag):
				continue
			tags_tree.get_root().create_child().set_text(0, tag)
			current_count += 1
			if step <= current_count:
				break
	
	pages_lbl.text = "/ " + str(maxi(1, ceili(current_tags.size() / float(step))))
	set_next_arrow_disabled(current_tags.size() < ((value + 1) * step))


func clear_progress_tooltip() -> void:
	esix_cooldown_bar.tooltip_text = ""


func on_cooldown_finished() -> void:
	_api_working = false


func clear_tags() -> void:
	for tag in tags_tree.get_root().get_children():
		tag.free()


func set_prev_arrow_disabled(set_disabled: bool) -> void:
	prev_button.disabled = set_disabled
	prev_button.focus_mode = Control.FOCUS_ALL if not set_disabled else Control.FOCUS_NONE


func set_next_arrow_disabled(set_disabled: bool) -> void:
	next_button.disabled = set_disabled
	next_button.focus_mode = Control.FOCUS_ALL if not set_disabled else Control.FOCUS_NONE
