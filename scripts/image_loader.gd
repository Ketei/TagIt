extends Node


signal http_responded(result: Array)
signal full_image_responded(result: Array)

var http_requester: HTTPRequest
var full_requester: HTTPRequest


func _ready():
	http_requester = HTTPRequest.new()
	http_requester.timeout = 10
	http_requester.request_completed.connect(on_http_response)
	add_child(http_requester)
	full_requester = HTTPRequest.new()
	full_requester.timeout = 10
	full_requester.request_completed.connect(on_full_response)
	add_child(full_requester)


func load_web_image(url: String, headers: PackedStringArray) -> void:
	http_requester.request(url, headers)


func load_full_image(url: String, headers: PackedStringArray) -> void:
	full_requester.request(url, headers)


func on_http_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK or response_code != 200:
		emit_signal.call_deferred("http_responded", [false])
		return
	
	var _heads: Dictionary = parse_image_headers(headers)
	
	var texture: SpriteFrames = create_image_texture(
			body,
			_heads["content-type"].split("/")[1])
	
	emit_signal.call_deferred("http_responded", [true, texture])


func parse_image_headers(headers_array: PackedStringArray) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func create_image_texture(image_data: PackedByteArray, image_format: String) -> SpriteFrames:
	var image := Image.new()
	var return_texture: SpriteFrames = null
	
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
	return return_texture


func on_full_response(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != OK or response_code != 200:
		emit_signal.call_deferred("full_image_responded", [false])
		return
	
	var _heads: Dictionary = parse_image_headers(headers)
	
	var texture: Resource = create_image_texture(
			body,
			_heads["content-type"].split("/")[1])
	
	emit_signal.call_deferred("full_image_responded", [true, texture])
