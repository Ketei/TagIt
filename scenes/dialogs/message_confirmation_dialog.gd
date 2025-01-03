extends ConfirmationDialog


signal dialog_finished(is_confirmed: bool)


var message: String = "":
	set(new_message):
		message = new_message
		if is_node_ready():
			_message_label.text = message
			size = Vector2i.ZERO
var _message_label: Label = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_position = WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_message_label.custom_minimum_size.y = 32
	_message_label.text = message
	size = Vector2i.ZERO
	add_child(_message_label)
	
	confirmed.connect(on_confirmed)
	canceled.connect(on_cancelled)


func on_confirmed() -> void:
	dialog_finished.emit(true)


func on_cancelled() -> void:
	dialog_finished.emit(false)
