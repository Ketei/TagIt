extends ConfirmationDialog


signal dialog_finished(success: bool, text: String)

var _submit_ln_edt: LineEdit
var allow_empty: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not allow_empty:
		get_ok_button().disabled = true
	_submit_ln_edt = LineEdit.new()
	add_child(_submit_ln_edt)
	_submit_ln_edt.custom_minimum_size.y = 32
	size = Vector2(220, 90)
	ok_button_text = "Confirm"
	initial_position = WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	_submit_ln_edt.text_changed.connect(on_text_changed)
	_submit_ln_edt.text_submitted.connect(on_line_submitted)
	confirmed.connect(on_confirmed)
	canceled.connect(on_cancelled)


func on_confirmed() -> void:
	dialog_finished.emit(true, _submit_ln_edt.text.strip_edges())


func on_cancelled() -> void:
	dialog_finished.emit(false, "")


func on_line_submitted(text_submitted: String) -> void:
	if not get_ok_button().disabled:
		dialog_finished.emit(true, text_submitted.strip_edges())
	hide()


func on_text_changed(new_text: String) -> void:
	if allow_empty:
		return
	get_ok_button().disabled = new_text.strip_edges().is_empty()
