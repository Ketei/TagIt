extends PanelContainer


signal tags_split(tags: PackedStringArray)
signal split_cancelled

@onready var tags_text: TextEdit = $MainCenter/MainPanel/MainMargin/MainContainer/TagsText
@onready var white_space_ln_edt: TextEdit = $MainCenter/MainPanel/MainMargin/MainContainer/HBoxContainer/WhiteSpaceLnEdt
@onready var separator_ln_edt: TextEdit = $MainCenter/MainPanel/MainMargin/MainContainer/HBoxContainer/SeparatorLnEdt
@onready var cancel_button: Button = $MainCenter/MainPanel/MainMargin/MainContainer/ButtonContainer/CancelButton
@onready var save_button: Button = $MainCenter/MainPanel/MainMargin/MainContainer/ButtonContainer/SaveButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	save_button.pressed.connect(on_accept_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_focus_next"):
		if tags_text.has_focus():
			if event.shift_pressed:
				white_space_ln_edt.grab_focus()
			else:
				cancel_button.grab_focus()
			get_viewport().set_input_as_handled()
		elif white_space_ln_edt.has_focus():
			if event.shift_pressed:
				tags_text.grab_focus()
			else:
				separator_ln_edt.grab_focus()
			get_viewport().set_input_as_handled()
		elif separator_ln_edt.has_focus():
			if event.shift_pressed:
				white_space_ln_edt.grab_focus()
			else:
				save_button.grab_focus()
			get_viewport().set_input_as_handled()


func on_accept_pressed() -> void:
	tags_split.emit(
			Strings.split_tags(
					tags_text.text.strip_edges(),
					white_space_ln_edt.text,
					separator_ln_edt.text))


func on_cancel_pressed() -> void:
	split_cancelled.emit()
