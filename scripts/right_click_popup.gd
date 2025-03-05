class_name RightClickPopupMenu
extends PopupMenu


func show_in_bounds(origin: Vector2i) -> void:
	var allowed_area: Vector2i = DisplayServer.window_get_size()
	allowed_area -= size
	var new_origin = Vector2i(
			clampi(origin.x, 0, allowed_area.x),
			clampi(origin.y, 0, allowed_area.y))
	position = new_origin
	show()
