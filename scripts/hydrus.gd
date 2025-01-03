class_name HydrusWorker
extends Node


signal create_frames(frame_data: Dictionary)
signal frames_created(frames_res: ImageFrames)
signal frames_loading_finished

signal full_image_loaded(image: SpriteFrames, is_animated: bool)
signal load_full_image(image_data: PackedByteArray, image_format: String)


func _ready():
	create_frames.connect(create_image_texture)
	load_full_image.connect(load_full)


func create_image_texture(frame_data: Dictionary) -> void:
	for image_id in frame_data:
		var image := Image.new()
		var return_texture: SpriteFrames = null
		if frame_data[image_id]["format"] == "jpeg" or frame_data[image_id]["format"] == "jpg":
			image.load_jpg_from_buffer(frame_data[image_id]["data"])
			image.generate_mipmaps()
			return_texture = SpriteFrames.new()
			var frame_texture: Texture2D = ImageTexture.create_from_image(image)
			return_texture.add_frame("default", frame_texture)
		elif frame_data[image_id]["format"] == "png":
			image.load_png_from_buffer(frame_data[image_id]["data"])
			image.generate_mipmaps()
			return_texture = SpriteFrames.new()
			var frame_texture: Texture2D = ImageTexture.create_from_image(image)
			return_texture.add_frame(&"default", frame_texture)
		elif frame_data[image_id]["format"] == "gif":
			return_texture = GifManager.sprite_frames_from_buffer(frame_data[image_id]["data"])
			return_texture.rename_animation(&"gif", &"default")
	
		frames_created.emit(return_texture, image_id)
	frames_loading_finished.emit()


func load_full(image_data: PackedByteArray, image_format: String) -> void:
	var image := Image.new()
	var return_texture: SpriteFrames = null
	var animated: bool = false
	
	if image_format == "jpeg" or image_format == "jpg":
		image.load_jpg_from_buffer(image_data)
		image.generate_mipmaps()
		return_texture = SpriteFrames.new()
		var frame_texture: Texture2D = ImageTexture.create_from_image(image)
		return_texture.add_frame("default", frame_texture)
	elif image_format == "png":
		image.load_png_from_buffer(image_data)
		image.generate_mipmaps()
		return_texture = SpriteFrames.new()
		var frame_texture: Texture2D = ImageTexture.create_from_image(image)
		return_texture.add_frame(&"default", frame_texture)
	elif image_format == "gif":
		return_texture = GifManager.sprite_frames_from_buffer(image_data)
		return_texture.rename_animation(&"gif", &"default")
		animated = true
	full_image_loaded.emit(return_texture, animated)
