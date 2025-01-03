extends PanelContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var first_node: Control = null
	for child in get_children():
		if child is Control:
			if first_node != null:
				first_node = child
			child.visibility_changed.connect(on_visibility_changed.bind(child))
	if first_node != null:
		first_node.visible = true


func on_visibility_changed(child_changed: Control) -> void:
	if child_changed.visible:
		for child in get_children():
			if child == child_changed:
				continue
			if child is Control and child.visible:
				child.visible = false
