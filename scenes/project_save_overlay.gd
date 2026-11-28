class_name ProjectSaveOverlay
extends Control

signal project_finished(is_save: bool, title: String, description: String)

enum SlideOrigin {
	BOTTOM,
	TOP,
}

const BACKGROUND_ALPHA: float = 0.7
const FADE_DURATION: float = 0.35
const SLIDE_DURATION: float = 0.85
const BUTTONS_FADE_DURATION: float = 0.25
const BUTTONS_GAP_Y: float = 16.0
const CARD_SIZE: Vector2 = TagItProjectCard.CARD_SIZE
const CARD_CENTER_SCALE: float = 1.15
const START_ROTATION: float = 0.12

@export var slide_from: SlideOrigin = SlideOrigin.BOTTOM

@onready var back_color: ColorRect = $BackColor

@onready var buttons_container: HBoxContainer = $ButtonsContainer
@onready var cancel_button: Button = $ButtonsContainer/CancelButton
@onready var save_button: Button = $ButtonsContainer/SaveButton


var _base_viewport_size := Vector2(1280.0, 720.0)
var _dynamic_scale: float = CARD_CENTER_SCALE
var _card: TagItProjectCard
var _is_animating: bool = false


func _ready() -> void:
	var window := get_window()
	window.min_size = Vector2i(1280, 720)
	
	visible = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	get_viewport().size_changed.connect(_on_viewport_size_changed, CONNECT_DEFERRED)
	
	buttons_container.visible = false
	buttons_container.modulate.a = 0.0
	cancel_button.pressed.connect(_on_cancel_pressed)
	save_button.pressed.connect(_on_save_pressed)
	
	_recalculate_scale()
	_spawn_edit_card()
	
	await get_tree().create_timer(1.0).timeout
	open(
		"New Project",
		"",
		load("res://textures/ready.png"))


func _spawn_edit_card() -> void:
	_card = TagItProjectCard.new()
	_card.edit_mode = true
	_card.button_visible = false
	_card.pivot_offset = CARD_SIZE * 0.5
	add_child(_card)
	move_child(_card, buttons_container.get_index())


func open(initial_title: String = "", initial_description: String = "", thumbnail: Texture2D = null) -> void:
	if _is_animating:
		return
	
	_is_animating = true
	_recalculate_scale()
	
	_card.set_card_title(initial_title)
	_card.set_card_description(initial_description)
	if thumbnail != null:
		_card.set_card_texture(thumbnail)
	
	var center_pos: Vector2 = _get_center_position()
	var offscreen_y: float = _get_offscreen_y()
	var initial_rot: float = START_ROTATION if slide_from == SlideOrigin.BOTTOM else -START_ROTATION
	
	_card.position = Vector2(center_pos.x, offscreen_y)
	_card.scale = Vector2.ONE * _dynamic_scale
	_card.rotation = initial_rot
	_card.visible = true
	
	_update_buttons_layout()
	buttons_container.modulate.a = 0.0
	buttons_container.visible = false
	
	back_color.color = Color(0.0, 0.0, 0.0, 0.0)
	back_color.visible = true
	visible = true
	
	await _fade_in_bg()
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_card, ^"position:y", center_pos.y, SLIDE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(_card, ^"rotation", 0.0, SLIDE_DURATION).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	
	buttons_container.visible = true
	var btn_tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	btn_tween.tween_property(buttons_container, ^"modulate:a", 1.0, BUTTONS_FADE_DURATION)
	await btn_tween.finished
	
	_is_animating = false
	_card.focus_title()


func close(invert: bool = false, rotate: bool = true) -> void:
	if _is_animating or not visible:
		return
	
	var slide_target: SlideOrigin = slide_from
	if invert:
		if slide_target == SlideOrigin.BOTTOM:
			slide_target = SlideOrigin.TOP
		else:
			slide_target = SlideOrigin.BOTTOM
	
	_is_animating = true
	var offscreen_y: float = _get_offscreen_y(slide_target)
	var exit_rot: float = 0.0
	
	if invert:
		exit_rot = START_ROTATION if slide_from == SlideOrigin.BOTTOM else -START_ROTATION
	else:
		exit_rot = -START_ROTATION if slide_from == SlideOrigin.BOTTOM else START_ROTATION
		
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_card, ^"position:y", offscreen_y, SLIDE_DURATION * 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	if rotate:
		tween.tween_property(_card, ^"rotation", exit_rot, SLIDE_DURATION * 0.8).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.tween_property(buttons_container, ^"modulate:a", 0.0, BUTTONS_FADE_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	await tween.finished
	await _fade_out_bg()
	
	buttons_container.visible = false
	_is_animating = false
	visible = false



func _on_cancel_pressed() -> void:
	if _is_animating:
		return
	project_finished.emit(false, "", "")


func _on_save_pressed() -> void:
	if _is_animating:
		return
	project_finished.emit(
			true,
			_card.get_card_title(),
			_card.get_card_description())


func _update_buttons_layout() -> void:
	var vp_size: Vector2 = size if size.x > 0.0 and size.y > 0.0 else _base_viewport_size
	var height_ratio: float = vp_size.y / _base_viewport_size.y
	var scaled_card_size: Vector2 = CARD_SIZE * _dynamic_scale
	var card_bottom_y: float = (vp_size.y + scaled_card_size.y) * 0.5
	
	buttons_container.size.x = scaled_card_size.x
	buttons_container.position = Vector2(
		(vp_size.x - scaled_card_size.x) * 0.5,
		card_bottom_y + BUTTONS_GAP_Y * height_ratio
	)


func _fade_in_bg() -> void:
	var tween := create_tween().set_parallel()
	tween.tween_property(
			back_color,
			^"color:a",
			BACKGROUND_ALPHA,
			FADE_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	await tween.finished


func _fade_out_bg() -> void:
	var tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(
		back_color,
		^"color:a",
		0.0,
		FADE_DURATION)
	await tween.finished


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _is_animating:
		return
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		project_finished.emit(false, "", "")


func _recalculate_scale() -> void:
	var win := get_window()
	if win != null and win.min_size.x > 0 and win.min_size.y > 0:
		_base_viewport_size = Vector2(win.min_size)
	
	var vp_size: Vector2 = size if size.x > 0.0 and size.y > 0.0 else _base_viewport_size
	var height_ratio: float = vp_size.y / _base_viewport_size.y
	_dynamic_scale = CARD_CENTER_SCALE * height_ratio


func _get_center_position() -> Vector2:
	var vp_size: Vector2 = size if size.x > 0.0 and size.y > 0.0 else _base_viewport_size
	return (vp_size - CARD_SIZE) * 0.5


func _get_offscreen_y(slide: SlideOrigin = slide_from) -> float:
	var vp_size: Vector2 = size if size.x > 0.0 and size.y > 0.0 else _base_viewport_size
	var scaled_h: float = CARD_SIZE.y * _dynamic_scale
	var unscaled_pad: float = (CARD_SIZE.y - scaled_h) * 0.5
	
	if slide == SlideOrigin.BOTTOM:
		return vp_size.y - unscaled_pad + 20.0
	return -scaled_h - unscaled_pad - 20.0


func _on_viewport_size_changed() -> void:
	_recalculate_scale()
	if not visible or _is_animating or _card == null:
		return
	
	_card.scale = Vector2.ONE * _dynamic_scale
	_card.position = _get_center_position()
	_update_buttons_layout()
