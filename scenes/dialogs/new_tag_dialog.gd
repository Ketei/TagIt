extends ConfirmationDialog


signal creation_finished(is_success: bool, tag_name: String)

@onready var new_tag_ln_edt: LineEdit = $MainContainer/NewTagLnEdt


func _ready() -> void:
	canceled.connect(on_dialog_cancelled)
	confirmed.connect(on_dialog_confirmed)
	new_tag_ln_edt.focus_next = get_ok_button().get_path()
	get_ok_button().focus_previous = new_tag_ln_edt.get_path()
	get_cancel_button().focus_next = new_tag_ln_edt.get_path()
	new_tag_ln_edt.focus_previous = get_cancel_button().get_path()
	get_ok_button().disabled = true
	
	new_tag_ln_edt.text_changed.connect(on_tag_line_changed)
	new_tag_ln_edt.text_submitted.connect(on_text_submitted)


func focus_first() -> void:
	new_tag_ln_edt.grab_focus()


func on_text_submitted(text: String) -> void:
	if not text.strip_edges().is_empty():
		creation_finished.emit(true, new_tag_ln_edt.text.strip_edges().to_lower())
		hide()


func on_tag_line_changed(new_line: String) -> void:
	get_ok_button().disabled = new_line.strip_edges().is_empty()


func on_dialog_cancelled() -> void:
	creation_finished.emit(false, "")


func on_dialog_confirmed() -> void:
	creation_finished.emit(true, new_tag_ln_edt.text.strip_edges().to_lower())
	new_tag_ln_edt.clear()
