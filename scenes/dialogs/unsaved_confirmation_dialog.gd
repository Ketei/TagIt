extends AcceptDialog

# 0 = Save, 1 = Don't save, 2 = Cancel
signal dialog_finished(result: int)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var label := Label.new()
	add_child(label)
	label.text = "You have unsaved changes."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	size = Vector2(230, 90)
	initial_position = WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	add_button("Don't Save", true).pressed.connect(on_dont_save)
	add_cancel_button("Cancel")
	canceled.connect(on_cancelled)
	confirmed.connect(on_confirmed)


func on_confirmed() -> void:
	dialog_finished.emit(0)


func on_cancelled() -> void:
	dialog_finished.emit(2)


func on_dont_save() -> void:
	dialog_finished.emit(1)
	hide()
