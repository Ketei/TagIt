extends ScrollContainer


signal thumbnail_pressed(image_id: int, image_idx: int)


var thumbnail_dimensions: Vector2i = Vector2i(100, 100)

@onready var images_container: HFlowContainer = $ImagesContainer


func create_image(image_texture: Texture2D, image_id: int) -> void:
	var n_left: TextureButton = null if images_container.get_child_count() == 0 else images_container.get_child(-1)
	
	var new_thumbnail := TextureButton.new()
	new_thumbnail.ignore_texture_size = true
	new_thumbnail.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	new_thumbnail.texture_normal = image_texture
	new_thumbnail.texture_focused = preload("res://textures/thumbnail_focus.png")
	new_thumbnail.custom_minimum_size = thumbnail_dimensions
	new_thumbnail.focus_mode = Control.FOCUS_ALL
	images_container.add_child(new_thumbnail)
	new_thumbnail.pressed.connect(on_thumbnail_pressed.bind(image_id, new_thumbnail.get_index()))
	new_thumbnail.set_meta(&"image_id", image_id)
	
	if n_left != null:
		new_thumbnail.focus_neighbor_left = n_left.get_path()
		n_left.focus_neighbor_right = new_thumbnail.get_path()
	else:
		new_thumbnail.focus_neighbor_left = $"../WikiDets/ReloadImagesButton".get_path()


func on_thumbnail_pressed(image_id: int, img_idx: int) -> void:
	thumbnail_pressed.emit(image_id, img_idx)


func clear_gallery() -> void:
	for child in images_container.get_children():
		child.queue_free()
		images_container.remove_child(child)


func set_thumbnail_size(dimensions: Vector2i) -> void:
	thumbnail_dimensions = dimensions
	for thumbnail:Control in images_container.get_children():
		thumbnail.custom_minimum_size = dimensions
