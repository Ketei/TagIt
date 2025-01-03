extends ConfirmationDialog


signal dialog_finished(success: bool, color: String)
@onready var color_select: ColorPickerButton = $HBoxContainer/ColorPickerButton


func _ready() -> void:
	confirmed.connect(on_confirm)
	canceled.connect(on_cancelled)
	color_select.focus_next = get_ok_button().get_path()
	get_ok_button().focus_previous = color_select.get_path()
	get_cancel_button().focus_next = color_select.get_path()


func focus_first() -> void:
	color_select.grab_focus()


func set_color(color: String) -> void:
	color_select.color = Color.from_string(color, Color.WHITE)


func on_confirm() -> void:
	dialog_finished.emit(
			true,
			color_select.color.to_html(false))


func on_cancelled() -> void:
	dialog_finished.emit(false, "")
