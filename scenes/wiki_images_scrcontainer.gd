extends ScrollContainer


signal thumbnail_pressed(image_id: int, image_idx: int)


var thumbnail_dimensions: Vector2i = Vector2i(100, 100)

@onready var images_container: HFlowContainer = $ImagesContainer


func create_image(image_texture: Texture2D, image_id: int) -> void:
	var new_thumbnail := TextureButton.new()
	new_thumbnail.ignore_texture_size = true
	new_thumbnail.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	new_thumbnail.texture_normal = image_texture
	new_thumbnail.custom_minimum_size = thumbnail_dimensions
	images_container.add_child(new_thumbnail)
	new_thumbnail.pressed.connect(on_thumbnail_pressed.bind(image_id, new_thumbnail.get_index()))
	new_thumbnail.set_meta(&"image_id", image_id)


func on_thumbnail_pressed(image_id: int, img_idx: int) -> void:
	thumbnail_pressed.emit(image_id, img_idx)


func clear_gallery() -> void:
	for child in images_container.get_children():
		child.queue_free()


func set_thumbnail_size(dimensions: Vector2i) -> void:
	thumbnail_dimensions = dimensions
	for thumbnail:Control in images_container.get_children():
		thumbnail.custom_minimum_size = dimensions
