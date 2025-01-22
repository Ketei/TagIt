extends Tree


signal tags_dropped(tags: Array[String])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has_all(["type", "tag_names"]) and (data["type"] == "tag_array" or data["type"] == "tag_list")


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	tags_dropped.emit(data["tag_names"])
