extends LineEdit


@export_enum("Down", "Up") var list_direction: int = 0
@export_range(1, 20, 1, "or_greater") var item_limit: int = 10
@export var replace_on_item_select: bool = false

var close_event: StringName = &""
var open_event: StringName = &""

@onready var autofill_list: ItemList = $AutofillList


func _ready() -> void:
	if list_direction == 0:
		close_event = &"ui_up"
		open_event = &"ui_down"
		autofill_list.anchor_left = 0
		autofill_list.anchor_right = 1
		autofill_list.anchor_top = 1
		autofill_list.anchor_bottom = 1
		autofill_list.grow_horizontal = Control.GROW_DIRECTION_END
		autofill_list.grow_vertical = Control.GROW_DIRECTION_END
	else:
		close_event = &"ui_down"
		open_event = &"ui_up"
		autofill_list.anchor_left = 0
		autofill_list.anchor_right = 1
		autofill_list.anchor_top = 0
		autofill_list.anchor_bottom = 0
		autofill_list.grow_horizontal = Control.GROW_DIRECTION_END
		autofill_list.grow_vertical = Control.GROW_DIRECTION_BEGIN
	
	autofill_list.item_clicked.connect(on_list_item_selected)
	autofill_list.focus_exited.connect(on_list_focus_lost)
	text_submitted.connect(on_text_submitted)


func _input(event: InputEvent) -> void:
	if autofill_list.has_focus() and event is InputEventKey:
	#if event is InputEventKey:
		if Input.is_action_just_pressed(close_event) and autofill_list.is_selected((autofill_list.item_count - 1) * list_direction):
			grab_focus()
			autofill_list.visible = false
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed(&"ui_focus_next"):
			text = autofill_list.get_item_text(autofill_list.get_selected_items()[0])
			autofill_list.deselect_all()
			grab_focus()
			autofill_list.visible = false
			caret_column = text.length()
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed(&"ui_accept"):
			if replace_on_item_select:
				text = autofill_list.get_item_text(autofill_list.get_selected_items()[0])
			text_submitted.emit(autofill_list.get_item_text(autofill_list.get_selected_items()[0]))
			autofill_list.deselect_all()
			grab_focus()
			caret_column = text.length()
			autofill_list.visible = false
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"ui_right"):
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed(&"ui_up") and list_direction == 1:
			if autofill_list.is_selected(0):
				autofill_list.select((autofill_list.item_count - 1) * list_direction)
				get_viewport().set_input_as_handled()
		elif event.is_action_pressed(&"ui_down") and list_direction == 0:
			if autofill_list.is_selected(autofill_list.item_count - 1):
				autofill_list.select(0)
				get_viewport().set_input_as_handled()
		elif event.is_pressed() and event.unicode != 0:
			grab_focus()
	elif has_focus() and event is InputEventKey:
		if Input.is_action_just_pressed(open_event) and 0 < autofill_list.item_count:
			autofill_list.visible = true
			autofill_list.grab_focus()
			autofill_list.select((autofill_list.item_count - 1) * list_direction)
			autofill_list.ensure_current_is_visible()
			get_viewport().set_input_as_handled()


func on_text_submitted(_text: String) -> void:
	if autofill_list.visible:
		autofill_list.visible = false
	if autofill_list.has_focus():
		grab_focus()


func on_list_focus_lost() -> void:
	hide_items()


func on_list_item_selected(index: int) -> void:
	if replace_on_item_select:
		text = autofill_list.get_item_text(index)
	text_submitted.emit(autofill_list.get_item_text(index))


func add_items(items: Array[String], clear_items: bool = true) -> void:
	if clear_items:
		autofill_list.clear()
	
	var count: int = 0

	if list_direction == 0:
		for item in items:
			count += 1
			autofill_list.add_item(item)
			if item_limit <= count:
				break
	else:
		for item_idx in range(items.size() - 1, -1, -1):
			count += 1
			autofill_list.add_item(items[item_idx])
			if item_limit <= count:
				break


func show_items() -> void:
	autofill_list.visible = true


func items_visible() -> bool:
	return autofill_list.visible


func hide_items() -> void:
	autofill_list.visible = false
