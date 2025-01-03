extends PanelContainer


signal load_next_image(current: int)
signal load_previous_image(current: int)

var _image_frames: SpriteFrames = null
var current_frame: int = 0
var frame_count: int = 0
var image_index: int = -1
var _spinner_tween: Tween

@onready var texture_rect: TextureRect = $ViewerContainer/ScrollZoomView/TextureRect
@onready var delta_timer: Node = $DeltaTimer
#@onready var panel_container: PanelContainer = $PanelContainer
@onready var throbber: TextureProgressBar = $ThrobberContainer/Throbber
@onready var image_viewer: ScrollZoomView = $ViewerContainer/ScrollZoomView
@onready var throbber_container: MarginContainer = $ThrobberContainer
@onready var viewer_container: PanelContainer = $ViewerContainer



func _ready() -> void:
	if visible:
		visible = false
	delta_timer.advance_frames.connect(on_advance_frame)
	viewer_container.visible = false
	throbber_container.visible = false


func _input(_event: InputEvent) -> void:
	if texture_rect.is_visible_in_tree():
		if Input.is_action_just_released(&"ui_cancel"):
			if not throbber_container.visible:
				viewer_container.visible = false
				if delta_timer.timer_running():
					delta_timer.stop_timer()
				image_index = -1
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed(&"ui_right"):
			load_next_image.emit(image_index)
			get_viewport().set_input_as_handled()
		elif Input.is_action_just_pressed(&"ui_left"):
			load_previous_image.emit(image_index)
			get_viewport().set_input_as_handled()


func set_image(frames: SpriteFrames, animated: bool) -> void:
	_image_frames = frames
	current_frame = 0
	frame_count = frames.get_frame_count(&"default")
	texture_rect.texture = _image_frames.get_frame_texture(&"default", current_frame)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image_viewer.scroll_offset = Vector2.ZERO
	image_viewer.reset_zoom()
	viewer_container.visible = true
	if animated:
		delta_timer.set_frame_duration(
			_image_frames.get_frame_duration(&"default", 0),
			_image_frames.get_animation_speed(&"default"))
		delta_timer.start_timer()
	if throbber_container.visible:
		hide_throbber()


func on_advance_frame(frame_advance: int) -> void:
	current_frame = (current_frame + frame_advance) % frame_count
	texture_rect.texture = _image_frames.get_frame_texture(&"default", current_frame)
	delta_timer.set_frame_duration(_image_frames.get_frame_duration(&"default", current_frame))


func show_spinner() -> void:
	throbber_container.visible = true
	_spinner_tween = create_tween()
	_spinner_tween.set_loops()
	_spinner_tween.tween_property(throbber, ^"radial_initial_angle", 360, 1.5).as_relative()


func hide_throbber() -> void:
	throbber_container.visible = false
	throbber.radial_initial_angle = 0
	if _spinner_tween != null:
		_spinner_tween.kill()
		_spinner_tween = null
