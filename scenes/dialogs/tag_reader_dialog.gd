extends ConfirmationDialog


signal tags_finished(tags: PackedStringArray)


var separator: String = "\n"

@onready var new_tags_txt_edt: TextEdit = $NewTagsTxtEdt


func _ready() -> void:
	confirmed.connect(_on_ok_pressed)
	canceled.connect(_on_canceled)


func _on_ok_pressed() -> void:
	tags_finished.emit(get_tags())


func _on_canceled() -> void:
	tags_finished.emit(PackedStringArray())


func get_tags() -> PackedStringArray:
	var input_tags := PackedStringArray()
	for tag in new_tags_txt_edt.text.split(separator, false):
		var clean_tag: String = tag.strip_edges().to_lower()
		if clean_tag.is_empty():
			continue
		if not input_tags.has(clean_tag):
			input_tags.append(clean_tag)
	
	return input_tags
