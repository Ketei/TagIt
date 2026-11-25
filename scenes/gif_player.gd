class_name GifTextureRect
extends TextureRect

@export var paused: bool = false:
	set(p):
		paused = p
		_update_process()

var _anim_name: StringName = &"gif"
var _current_frame: int = 0
var _elapsed_time: float = 0.0
var _frame_count: int = 0
var _textures: Array[Texture2D] = []
var _delays: PackedFloat32Array = PackedFloat32Array()

var _playing: bool = false:
	set(p):
		_playing = p
		_update_process()

var gif: SpriteFrames:
	set(g):
		stop()
		gif = g
		_textures.clear()
		_delays.clear()
		_frame_count = 0
		if gif == null:
			texture = null
			_update_process()
			return

		_frame_count = gif.get_frame_count(_anim_name)
		var fps: float = maxf(gif.get_animation_speed(_anim_name), 0.001)
		_textures.resize(_frame_count)
		_delays.resize(_frame_count)

		for i in range(_frame_count):
			_textures[i] = gif.get_frame_texture(_anim_name, i)
			_delays[i] = maxf(gif.get_frame_duration(_anim_name, i) / fps, 0.02)

		if _frame_count > 0:
			texture = _textures[0]
		else:
			texture = null
		_update_process()


func _ready() -> void:
	_update_process()


func play(from_start: bool = false) -> void:
	if gif == null or _frame_count == 0:
		return
	if from_start:
		set_frame(0)
	paused = false
	_playing = true


func stop() -> void:
	_playing = false
	paused = false
	_elapsed_time = 0.0
	set_frame(0)


func set_frame(frame_index: int) -> void:
	if gif == null or _frame_count <= 0:
		return
	_current_frame = wrapi(frame_index, 0, _frame_count)
	_elapsed_time = 0.0
	texture = _textures[_current_frame]


func is_playing() -> bool:
	return _playing and not paused and gif != null


func _process(delta: float) -> void:
	if _frame_count <= 1:
		return

	_elapsed_time += delta
	var prev_frame: int = _current_frame

	while _elapsed_time >= _delays[_current_frame]:
		_elapsed_time -= _delays[_current_frame]
		_current_frame = (_current_frame + 1) % _frame_count

	if _current_frame != prev_frame:
		texture = _textures[_current_frame]


func _update_process() -> void:
	set_process(_playing and not paused and gif != null)
