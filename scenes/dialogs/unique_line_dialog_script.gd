extends ConfirmationDialog


signal dialog_confirmed(result: bool, text: String)


var blacklist: PackedStringArray = []
var placeholder_text: String = "":
	set(new_placeholder):
		placeholder_text = new_placeholder
		if is_node_ready():
			new_line.placeholder_text = new_placeholder
@onready var new_line: LineEdit = $NewLine


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_line.placeholder_text = placeholder_text
	get_ok_button().disabled = true
	new_line.text_changed.connect(_on_text_changed)
	new_line.text_submitted.connect(_on_text_submitted)


func _on_text_changed(new_text: String) -> void:
	var clean_text: String = new_text.strip_edges().to_lower()
	get_ok_button().disabled = clean_text.is_empty() or blacklist.has(clean_text)


func _on_text_submitted(new_text: String) -> void:
	var clean_text: String = new_text.strip_edges().to_lower()
	if clean_text.is_empty() or blacklist.has(clean_text):
		return
	hide()
	dialog_confirmed.emit(true, clean_text)


func _on_confirmed() -> void:
	dialog_confirmed.emit(true, new_line.text.strip_edges().to_lower())


func _on_canceled() -> void:
	dialog_confirmed.emit(false, "")


func focus_main() -> void:
	new_line.grab_focus()
