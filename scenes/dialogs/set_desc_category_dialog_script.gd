extends ConfirmationDialog


signal dialog_finished(success: bool, new_desc: String, prefix: String)


@onready var desc_txt_edt: TextEdit = $VBoxContainer/DescTxtEdt
@onready var prefix_ln_edt: LineEdit = $VBoxContainer/HydrusContainer/PrefixLnEdt


func _ready() -> void:
	desc_txt_edt.focus_next = get_ok_button().get_path()
	desc_txt_edt.focus_previous = get_cancel_button().get_path()
	get_ok_button().focus_previous = desc_txt_edt.get_path()
	get_cancel_button().focus_next = desc_txt_edt.get_path()
	
	confirmed.connect(on_dialog_finished.bind(true))
	canceled.connect(on_dialog_finished.bind(false))


func focus_first() -> void:
	desc_txt_edt.grab_focus()


func set_desc(desc: String) -> void:
	desc_txt_edt.text = desc


func set_prefix(prefix: String) -> void:
	prefix_ln_edt.text = prefix


func on_dialog_finished(is_success: bool) -> void:
	dialog_finished.emit(is_success, desc_txt_edt.text.strip_edges(), prefix_ln_edt.text.strip_edges().to_lower())
