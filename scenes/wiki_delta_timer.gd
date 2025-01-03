extends Node


signal advance_frames(frame_count: int)

var fps: float = 30.0
var _frame_duration: float = 0.01
var time_increase: int = 30
var timeout: float = 0.01
var _delta_count: float = 0.0
var _frame_counter: float = 1


func _ready() -> void:
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	_delta_count += delta
	if timeout < _delta_count:
		_frame_counter = _delta_count / timeout
		advance_frames.emit(_frame_counter)


func set_frame_duration(frame_speed_mult: float, speed: float = -1) -> void:
	if 0 < speed:
		fps = speed
		_frame_duration = 1 / fps
	timeout = _frame_duration * frame_speed_mult
	_delta_count = 0.0


func start_timer() -> void:
	set_physics_process(true)


func timer_running() -> bool:
	return is_physics_processing()


func stop_timer() -> void:
	_frame_counter = 0
	_delta_count = 0
	set_physics_process(false)
