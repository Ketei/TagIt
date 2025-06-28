extends PanelContainer


@onready var splash_opt_btn: OptionButton = $SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/SplashScreen/MainContainer/HBoxContainer/SplashOptBtn


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	splash_opt_btn.item_selected.connect(_on_splash_idx_selected)


func _on_splash_idx_selected(idx: int) -> void:
	var file_path: String = ProjectSettings.globalize_path("user://custom_splash.webp")
	var id: int = splash_opt_btn.get_item_id(idx)
	
	match id:
		0:
			if FileAccess.file_exists(file_path):
				OS.move_to_trash(file_path)
		1:
			var new_file_dialog := FileDialog.new()
			new_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
			new_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
			new_file_dialog.add_filter("*.png, *.jpg, *.jpeg, *.webp", "Image Files")
			new_file_dialog.use_native_dialog = true
			new_file_dialog.file_selected.connect(_on_file_finished.bind(new_file_dialog, true))
			new_file_dialog.canceled.connect(_on_file_finished.bind("", new_file_dialog, false))
			add_child(new_file_dialog)
			new_file_dialog.show()


func _on_file_finished(path: String, dialog: FileDialog, success: bool) -> void:
	if not success:
		splash_opt_btn.select(0)
		dialog.queue_free()
		return
	
	var img: Image = Image.load_from_file(path)
	if img != null:
		var resized_img: Image = DataManager.resize_image_to_constraints(img)
		resized_img.save_webp(
				ProjectSettings.globalize_path("user://custom_splash.webp"),
				false,
				1.0)
	
	dialog.queue_free()
