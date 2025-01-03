extends ConfirmationDialog


signal dialog_finished(success: bool, group_name: String, group_desc: String)


var ok_button: Button = null

@onready var name_ln_edt: LineEdit = $MainContainer/NameContainer/NameLnEdt
@onready var desc_txt_edt: TextEdit = $MainContainer/DescTxtEdt


func _ready() -> void:
	ok_button = get_ok_button()
	ok_button.disabled = true
	
	desc_txt_edt.focus_next = get_ok_button().get_path()
	get_ok_button().focus_previous = desc_txt_edt.get_path()
	get_cancel_button().focus_next = name_ln_edt.get_path()
	name_ln_edt.focus_previous = get_cancel_button().get_path()
	
	name_ln_edt.text_changed.connect(on_group_name_changed)
	confirmed.connect(on_dialog_finish.bind(true))
	canceled.connect(on_dialog_finish.bind(false))


func focus_first() -> void:
	name_ln_edt.grab_focus()


func on_group_name_changed(text: String) -> void:
	var is_empty: bool = text.strip_edges().is_empty()
	if ok_button.disabled != is_empty:
		ok_button.disabled = is_empty


func on_dialog_finish(is_success: bool) -> void:
	dialog_finished.emit(
			is_success,
			name_ln_edt.text.strip_edges(),
			desc_txt_edt.text.strip_edges())
