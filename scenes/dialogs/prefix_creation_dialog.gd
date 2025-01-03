extends ConfirmationDialog


signal prefix_submitted(is_valid: bool, prefix: String)

var existing_prefixes: PackedStringArray
@onready var prefix_line_edit: LineEdit = $PrefixLineEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_ok_button().disabled = true
	prefix_line_edit.text_changed.connect(on_prefix_line_changed)
	prefix_line_edit.text_submitted.connect(on_prefix_line_text_submitted)
	confirmed.connect(on_accepted)
	canceled.connect(on_cancelled)


func on_prefix_line_changed(text: String) -> void:
	var clean_text: String = text.strip_edges()
	if clean_text.is_empty():
		get_ok_button().disabled = true
		return
	
	var first_unicode: int = text.unicode_at(0)
	var last_unicode: int = text.unicode_at(text.length() - 1)
	get_ok_button().disabled = existing_prefixes.has(clean_text) or Strings.is_invalid_prefix_character(first_unicode) or Strings.is_invalid_prefix_character(last_unicode)


func on_prefix_line_text_submitted(submitted_text: String):
	if get_ok_button().disabled:
		return
	prefix_submitted.emit(true, submitted_text.strip_edges())
	hide()


func on_accepted() -> void:
	prefix_submitted.emit(true, prefix_line_edit.text.strip_edges())


func on_cancelled() -> void:
	prefix_submitted.emit(false, "")


#func is_letter_or_number(unicode: int) -> bool:
	## Mayus
	#return Math.is_between(unicode, 65, 90) or\
			## Minus
			#Math.is_between(unicode, 97, 122) or\
			## Numbers
			#Math.is_between(unicode, 48, 57) or\
			## "_"
			#unicode == 95
