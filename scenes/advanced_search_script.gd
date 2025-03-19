extends PanelContainer


signal search_pressed(search_args: Dictionary)
signal cancel_pressed

@export var starting_position: Vector2 = Vector2.ZERO

@onready var tag_ln_edt: LineEdit = $MainContainer/TagContainer/TagLnEdt
@onready var category_opt_btn: OptionButton = $MainContainer/CatContainer/CategoryOptBtn
@onready var prio_spn_box: SpinBox = $MainContainer/PrioContainer/PrioSpnBox
@onready var prio_opt_btn: OptionButton = $MainContainer/PrioContainer/PrioOptBtn
@onready var group_opt_btn: OptionButton = $MainContainer/GroupContainer/GroupOptBtn
@onready var valid_opt_btn: OptionButton = $MainContainer/ValidContainer/ValidOptBtn
@onready var close_btn: Button = $MainContainer/ButtonContainer/CloseBtn
@onready var search_btn: Button = $MainContainer/ButtonContainer/SearchBtn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = starting_position
	size = Vector2(307, 252)
	group_opt_btn.get_popup().max_size.y = 300
	category_opt_btn.get_popup().max_size.y = 300
	
	var categories := SingletonManager.TagIt.get_categories()
	var groups := SingletonManager.TagIt.get_tag_groups()
	
	for category in categories:
		category_opt_btn.add_icon_item(
			SingletonManager.TagIt.get_icon_texture(categories[category]["icon_id"]),
			categories[category]["name"],
			category)
	
	var group_arrays: Array[Array] = []
	
	for group in groups:
		group_arrays.append([group, groups[group]["name"]])
	
	group_arrays.sort_custom(_sort_custom_category)
	
	for group in group_arrays:
		group_opt_btn.add_item(
				group[1],
				group[0])
	
	search_btn.pressed.connect(_on_search_pressed)
	close_btn.pressed.connect(_on_cancel_pressed)
	prio_opt_btn.item_selected.connect(_on_prio_selected)
	
	tag_ln_edt.text_submitted.connect(_on_text_submitted)
	
	SingletonManager.TagIt.category_created.connect(_on_category_created)
	SingletonManager.TagIt.category_deleted.connect(_on_category_deleted)
	
	SingletonManager.TagIt.group_created.connect(_on_group_created)
	SingletonManager.TagIt.group_deleted.connect(_on_group_deleted)


func _sort_custom_category(a: Array, b: Array) -> bool:
	return a[1].naturalnocasecmp_to(b[1]) < 0


func _on_category_created(category_id: int) -> void:
	var category_data: Dictionary =  SingletonManager.TagIt.get_category_data(category_id)
	
	category_opt_btn.add_icon_item(
			SingletonManager.TagIt.get_icon_texture(category_data["icon_id"]),
			category_data["name"],
			category_id)


func _on_category_deleted(cat_id: int):
	for category in range(category_opt_btn.item_count):
		if category_opt_btn.get_item_id(category) == cat_id:
			category_opt_btn.remove_item(category)
			break


func _on_group_created(group_id: int, group_name: String) -> void:
	var group_array: Array[Array] = [[group_id, group_name]]
	var selected: int = group_opt_btn.get_selected_id()
	var new_selected: int = 0
	
	for group in range(group_opt_btn.item_count):
		group_array.append([group_opt_btn.get_item_id(group), group_opt_btn.get_item_text(group)])
	
	group_opt_btn.clear()
	group_array.sort_custom(_sort_custom_category)
	
	var idx: int = -1
	for group in group_array:
		idx += 1
		group_opt_btn.add_item(group[1], group[0])
		if group[0] == selected:
			new_selected = idx
	
	group_opt_btn.select(new_selected)


func _on_group_deleted(group_id: int) -> void:
	for idx in range(group_opt_btn.item_count):
		if group_opt_btn.get_item_id(idx) == group_id:
			group_opt_btn.remove_item(idx)
			break


func _on_prio_selected(idx: int) -> void:
	prio_spn_box.editable = 0 < idx


func _on_search_pressed() -> void:
	var args: Dictionary = {
		"text": tag_ln_edt.text.strip_edges().to_lower(),
		"category": category_opt_btn.get_selected_id(),
		"priority": {
			"use": 0 < prio_opt_btn.selected,
			"operator": operator_to_string(prio_opt_btn.get_selected_id()),
			"priority": int(prio_spn_box.value)},
		"group": group_opt_btn.get_selected_id(),
		"valid": valid_opt_btn.get_selected_id()}
	
	
	search_pressed.emit(args)


func _on_cancel_pressed() -> void:
	cancel_pressed.emit()
	if close_btn.has_focus():
		close_btn.release_focus()


func _on_text_submitted(text: String) -> void:
	if text.strip_edges().is_empty():
		return
	_on_search_pressed()


func clear_fields() -> void:
	tag_ln_edt.clear()
	category_opt_btn.select(0)
	prio_spn_box.value = 0
	prio_opt_btn.select(0)
	group_opt_btn.select(0)
	valid_opt_btn.select(0)


func focus_main() -> void:
	tag_ln_edt.grab_focus()
	tag_ln_edt.select_all()


func operator_to_string(operator: int) -> String:
	match operator:
		OP_EQUAL:
			return "="
		OP_GREATER_EQUAL:
			return ">="
		OP_LESS_EQUAL:
			return "<="
		_:
			return "="
