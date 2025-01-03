extends ConfirmationDialog

signal dialog_finished(success: bool, from: String, to: String)


@onready var antecedent_ln_edt: LineEdit = $MainContainer/AntecedentLnEdt
@onready var consequent_ln_edt: LineEdit = $MainContainer/ConsequentLnEdt


func _ready() -> void:
	get_ok_button().disabled = true
	antecedent_ln_edt.text_changed.connect(on_text_updated)
	consequent_ln_edt.text_changed.connect(on_text_updated)
	consequent_ln_edt.focus_next = get_ok_button().get_path()
	antecedent_ln_edt.focus_previous = get_cancel_button().get_path()
	get_cancel_button().focus_next = antecedent_ln_edt.get_path()
	get_ok_button().focus_previous = consequent_ln_edt.get_path()
	confirmed.connect(on_confirmed)
	canceled.connect(on_cancelled)


func on_text_updated(_text: String) -> void:
	get_ok_button().disabled = antecedent_ln_edt.text.strip_edges().is_empty() or consequent_ln_edt.text.strip_edges().is_empty()


func on_confirmed() -> void:
	dialog_finished.emit(
			true,
			antecedent_ln_edt.text.strip_edges().to_lower(),
			consequent_ln_edt.text.strip_edges().to_lower())


func on_cancelled() -> void:
	dialog_finished.emit(false, "", "")
