extends ConfirmationDialog


signal site_concluded(is_success: bool, site_name: String, tag_whitespace: String, site_separator: String)

@onready var site_name_ln_edt: LineEdit = $MainContainer/SiteNameLnEdt
@onready var whitespace_ln_edt: LineEdit = $MainContainer/DataContainer/WhitespaceContainer/WhitespaceLnEdt
@onready var separator_ln_edit: LineEdit = $MainContainer/DataContainer/SeparatorContainer/SeparatorLnEdit



func _ready() -> void:
	confirmed.connect(on_confirmed)
	canceled.connect(on_cancelled)
	separator_ln_edit.focus_next = get_ok_button().get_path()
	get_ok_button().focus_previous = separator_ln_edit.get_path()
	get_cancel_button().focus_next = site_name_ln_edt.get_path()
	site_name_ln_edt.focus_previous = get_cancel_button().get_path()
	
	whitespace_ln_edt.text_changed.connect(on_data_changed)
	separator_ln_edit.text_changed.connect(on_data_changed)
	get_ok_button().disabled = true


func focus_first() -> void:
	site_name_ln_edt.grab_focus()


func on_data_changed(_text: String) -> void:
	get_ok_button().disabled = whitespace_ln_edt.text.is_empty() or separator_ln_edit.text.is_empty()


func on_confirmed() -> void:
	site_concluded.emit(
			true,
			site_name_ln_edt.text.strip_edges(),
			whitespace_ln_edt.text,
			separator_ln_edit.text)


func on_cancelled() -> void:
	site_concluded.emit(
			false,
			"",
			"",
			"")
