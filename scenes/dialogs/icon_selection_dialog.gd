extends ConfirmationDialog


signal icon_finished(success: bool, icon_name: String, image: Image)


@onready var icon_name_txt_edt: LineEdit = $MainContainer/DataContainer/IconNameTxtEdt
@onready var browse_btn: Button = $MainContainer/DataContainer/BrowseBtn
@onready var icon_texture: TextureRect = $MainContainer/IconTexture
@onready var file_dialog: FileDialog = $FileDialog


func _ready() -> void:
	get_ok_button().disabled = true
	browse_btn.pressed.connect(on_browse_icon_pressed)
	file_dialog.file_selected.connect(on_icon_file_selected)
	browse_btn.focus_next = get_ok_button().get_path()
	get_ok_button().focus_previous = browse_btn.get_path()
	get_cancel_button().focus_next = icon_name_txt_edt.get_path()
	icon_name_txt_edt.focus_previous = get_cancel_button().get_path()
	confirmed.connect(on_confirmed)
	canceled.connect(on_cancelled)


func focus_first() -> void:
	icon_name_txt_edt.grab_focus()


func on_cancelled() -> void:
	icon_finished.emit(
			false,
			"",
			null)


func on_confirmed() -> void:
	icon_finished.emit(
			true,
			icon_name_txt_edt.text.strip_edges(),
			icon_texture.texture.get_image())


func on_browse_icon_pressed() -> void:
	file_dialog.show()


func on_icon_file_selected(file: String) -> void:
	var image := Image.load_from_file(file)
	var texture := ImageTexture.create_from_image(image)
	icon_texture.texture = texture
	get_ok_button().disabled = false
