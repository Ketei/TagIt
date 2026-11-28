class_name CardDeckTable
extends Control


signal project_load_requested(project_id: String, card: TagItProjectCard)
signal project_erase_requested(project_id: String, card: TagItProjectCard)

const BACKGROUND_ALPHA: float = 0.7
const BACKGROUND_FADE_TIME: float = 0.85

const CARD_SIZE: Vector2 = TagItProjectCard.CARD_SIZE
const VERTICAL_OFFSET: float = 0.0 # Optional vertical shift from exact screen center
const SIDE_DECK_Y: float = -210.0 # Height of the side deck at base resolution
const PILE_ROTATION_RANGE: float = 0.06

const SEARCH_DEBOUNCE_TIME: float = 0.35
const SCROLL_SPEED: float = 0.45
const SMOOTH_SPEED: float = 12.0
const DEAL_DURATION: float = 0.85
const SLIDE_DURATION: float = 0.85

const FOCUS_DURATION: float = 0.45
const CARD_SPACING: float = 0.32
const PILE_EDGE_OFFSET: float = 0.50
const PILE_STACK_OFFSET := Vector2(0.0, 4.0)
const CENTER_SCALE: float = 1.2
const DECK_SCALE: float = 0.8
const RECALL_TIME: float = 0.25

const ENTER_DURATION: float = 0.7 # Duration for card zoom + fade out
const ENTER_SCALE_MULTIPLIER: float = 1.6 # Jow large the card zooms as you enter it

const ERASE_BUTTON_FADE: float = 0.2
const ERASE_BUTTON_GAP_Y: float = 16.0
const ERASE_LIFT_DISTANCE: float = 140.0
const ERASE_ANIM_DURATION: float = 0.8

const CENTER_SNAP_TOLERANCE: float = 0.02

var _base_viewport_size := Vector2(1280.0, 720.0)
var _height_ratio: float = 1.0
var _dynamic_spacing_t: float = CARD_SPACING
var _dynamic_base_y: float = 120.0
var _dynamic_side_deck_y: float = SIDE_DECK_Y
var _dynamic_center_scale: float = CENTER_SCALE
var _dynamic_deck_scale: float = DECK_SCALE
var _dynamic_stack_offset: Vector2 = PILE_STACK_OFFSET

@onready var back_color: ColorRect = $BackColor
@onready var search_bar: LineEdit = $SearchContainer/SearchBar
@onready var search_container: PanelContainer = $SearchContainer
@onready var erase_button: Button = $EraseButton

var _gui_active: bool = true
var _table_active: bool = false:
	set(a):
		if a == _table_active:
			return
		
		_table_active = a
		var enable_process: bool = a and not _table_empty
		set_process(enable_process)
		set_process_input(enable_process)
var _table_empty: bool = false:
	set(t):
		_table_empty = t
		var enable_process: bool = not t and _table_active
		set_process(enable_process)
		set_process_input(enable_process)

var _left_pile_x: float = 0.0
var _right_pile_x: float = 0.0
var _is_center_settled: bool = false

var all_cards: Array[TagItProjectCard] = []
var active_cards: Array[TagItProjectCard] = []
var side_cards: Array[TagItProjectCard] = []

var scroll_progress: float = 0.0
var target_scroll: float = 0.0
var _is_fading: bool = false
var _is_recalling: bool = false
var is_table_active: bool = false:
	set(a):
		return
	get():
		return _table_active and not _table_empty
var _button_tween: Tween
var search_timer: Timer

var left_deck_btn: Button
var right_deck_btn: Button


func _ready() -> void:
	set_process(is_table_active)
	set_process_input(is_table_active)
	get_viewport().size_changed.connect(_on_viewport_size_changed, CONNECT_DEFERRED)
	_recalculate_viewport_metrics()
	_setup_search_timer()
	_setup_deck_buttons()
	
	erase_button.visible = false
	erase_button.disabled = true
	erase_button.modulate = Color.TRANSPARENT
	erase_button.pressed.connect(_on_erase_button_pressed)
	
	#await get_tree().create_timer(1).timeout
	#var projects: = TagItProjectResource.get_projects()
	#for project in projects.get_project_ids():
		#var project_data: Dictionary = projects.get_display_card_data(project)
		#if project_data.is_empty():
			#continue
		#spawn_card(project, project_data["title"], "", project_data["thumbnail"])
	#await _fade_in()
	#await _slide_deck_in()
	#_deal_initial_cards()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _is_fading or _is_recalling or not is_table_active:
		return
	
	if event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		project_load_requested.emit("", null)


func open() -> void:
	await _fade_in()
	await _slide_deck_in()
	_deal_initial_cards()


func spawn_card(project_id: String, card_title: String, card_description: String, card_texture: ImageTexture) -> void:
	var offscreen_x: float = _get_offscreen_right_x()
	var card_item: int = all_cards.size()
	
	var card: TagItProjectCard = TagItProjectCard.new()
	card.project_id = project_id
	card.pile_rotation = randf_range(-0.06, 0.06)
	card.edit_mode = false
	card.button_visible = false
	card.set_card_title(card_title)
	card.set_card_description(card_description)
	card.set_card_texture(card_texture)
	card.card_selected.connect(_on_card_selected)
	
	card.position = Vector2(offscreen_x, _dynamic_base_y) + _dynamic_stack_offset * float(card_item)
	card.scale = Vector2.ONE * _dynamic_deck_scale
	card.rotation = card.pile_rotation
	card.z_index = 15 - mini(card_item, 14)
	add_child(card)
	all_cards.append(card)
	
	active_cards = all_cards.duplicate()
	_on_active_cards_size_changed()


func finish_open_transition(selected_card: TagItProjectCard) -> void:
	var offscreen_x: float = _get_offscreen_right_x()
	var tween := create_tween().set_parallel(true)
	var stack_idx: int = 0
	
	for i: int in all_cards.size():
		var card: TagItProjectCard = all_cards[i]
		if card == selected_card:
			continue
		var target_pos: Vector2 = Vector2(offscreen_x, _dynamic_base_y) + _dynamic_stack_offset * float(stack_idx)
		tween.tween_property(card, "position", target_pos, SLIDE_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		stack_idx += 1
	
	var enter_scale: Vector2 = Vector2.ONE * (_dynamic_center_scale * ENTER_SCALE_MULTIPLIER)
	if selected_card != null:
		tween.tween_property(selected_card, ^"scale", enter_scale, ENTER_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(selected_card, ^"modulate:a", 0.0, ENTER_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(search_bar, ^"modulate:a", 0.0, ENTER_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(back_color, ^"color:a", 0.0, BACKGROUND_FADE_TIME).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	if is_instance_valid(_button_tween) and _button_tween.is_valid():
		_button_tween.kill()
		_button_tween = null
		if erase_button.visible:
			erase_button.disabled = true
			tween.tween_property(erase_button, ^"modulate", Color.TRANSPARENT, ENTER_DURATION)
	
	await tween.finished
	if selected_card != null:
		selected_card.visible = false


func _fade_in() -> void:
	if back_color.visible or _is_fading:
		return
	
	back_color.color = Color.BLACK
	back_color.color.a = 0.0
	back_color.visible = true
	search_container.position.y = size.y
	_is_fading = true
	
	var col_tween: Tween = create_tween().set_parallel().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	col_tween.tween_property(
			back_color,
			^"color:a",
			BACKGROUND_ALPHA,
			BACKGROUND_FADE_TIME)
	col_tween.tween_property(
		search_container,
		^"position:y",
		size.y - 50,
		BACKGROUND_FADE_TIME)
	
	await col_tween.finished
	_is_fading = false


func _fade_search() -> void:
	var col_tween: Tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	col_tween.tween_property(
		search_container,
		^"position:y",
		size.y + 10, # Padding just in case
		0.5)
	
	await col_tween.finished


func _get_min_viewport_size() -> Vector2:
	var win := get_window()
	if win != null and win.min_size.x > 0 and win.min_size.y > 0:
		return Vector2(win.min_size)
	
	return Vector2(
		float(ProjectSettings.get_setting("display/window/size/viewport_width", 1280)),
		float(ProjectSettings.get_setting("display/window/size/viewport_height", 720)))


func _recalculate_viewport_metrics() -> void:
	_base_viewport_size = _get_min_viewport_size()
	var vp_size: Vector2 = size if size.x > 0.0 and size.y > 0.0 else _base_viewport_size
	_height_ratio = vp_size.y / _base_viewport_size.y
	
	_dynamic_center_scale = CENTER_SCALE * _height_ratio
	_dynamic_deck_scale = DECK_SCALE * _height_ratio
	_dynamic_stack_offset = PILE_STACK_OFFSET * _height_ratio
	
	_dynamic_base_y = (vp_size.y - CARD_SIZE.y) * 0.5 + VERTICAL_OFFSET * _height_ratio
	_dynamic_side_deck_y = _dynamic_base_y - ((_base_viewport_size.y - CARD_SIZE.y) * 0.5 - SIDE_DECK_Y) * _height_ratio
	
	var scaled_card_w: float = CARD_SIZE.x * _dynamic_deck_scale
	var unscaled_pad: float = (CARD_SIZE.x - scaled_card_w) * 0.5
	_left_pile_x = -scaled_card_w * PILE_EDGE_OFFSET - unscaled_pad
	_right_pile_x = vp_size.x - scaled_card_w * (1.0 - PILE_EDGE_OFFSET) - unscaled_pad
	
	var target_pixel_gap: float = _base_viewport_size.x * CARD_SPACING * _height_ratio
	_dynamic_spacing_t = clampf(target_pixel_gap / maxf(vp_size.x, 1.0), 0.05, 0.48)
	
	search_container.size.x = size.x / 4.0
	search_container.position.x = (size.x / 2.0) - (search_container.size.x / 2.0)
	if back_color.visible and search_bar.editable:
		search_container.position.y = size.y - 50.0
	else:
		search_container.position.y = size.y + 10.0
	
	var center_card_top_y: float = (vp_size.y - CARD_SIZE.y * _dynamic_center_scale) * 0.5 + VERTICAL_OFFSET * _height_ratio
	erase_button.position = Vector2(
		(vp_size.x - erase_button.size.x) * 0.5,
		center_card_top_y - erase_button.size.y - ERASE_BUTTON_GAP_Y * _height_ratio)


func _on_viewport_size_changed() -> void:
	_recalculate_viewport_metrics()
	_update_deck_buttons_layout()
	
	if not active_cards.is_empty():
		_evaluate_active_curve()
	
	for i: int in range(side_cards.size()):
		var card: TagItProjectCard = side_cards[i]
		card.position = Vector2(_right_pile_x + 25.0 * _height_ratio, _dynamic_side_deck_y) + _dynamic_stack_offset * float(i)
		card.scale = Vector2.ONE * (_dynamic_deck_scale * 0.82)


func _update_deck_buttons_layout() -> void:
	if left_deck_btn == null or right_deck_btn == null:
		return
	
	var deck_size: Vector2 = CARD_SIZE * _dynamic_deck_scale
	var unscaled_pad := (CARD_SIZE - deck_size) * 0.5
	
	left_deck_btn.position = Vector2(_left_pile_x, _dynamic_base_y) + unscaled_pad
	left_deck_btn.size = deck_size
	
	right_deck_btn.position = Vector2(_right_pile_x, _dynamic_base_y) + unscaled_pad
	right_deck_btn.size = deck_size


func _setup_deck_buttons() -> void:
	left_deck_btn = _create_deck_button()
	left_deck_btn.pressed.connect(_on_left_deck_pressed)
	add_child(left_deck_btn)
	
	right_deck_btn = _create_deck_button()
	right_deck_btn.pressed.connect(_on_right_deck_pressed)
	add_child(right_deck_btn)
	
	_update_deck_buttons_layout()


func _create_deck_button() -> Button:
	var btn := Button.new()
	btn.flat = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.mouse_filter = Control.MOUSE_FILTER_PASS
	return btn


func _set_erase_disabled(disabled: bool) -> void:
	erase_button.disabled = disabled
	_button_tween = null


func _set_erase_button_visible(make_visible: bool) -> void:
	erase_button.visible = make_visible
	_button_tween = null


func _fade_in_erase_button() -> void:
	if not erase_button.disabled or active_cards.is_empty():
		return
	
	if is_instance_valid(_button_tween) and _button_tween.is_valid():
		_button_tween.kill()
	
	erase_button.visible = true
	_button_tween = create_tween()
	_button_tween.tween_property(erase_button, ^"modulate", Color.WHITE, ERASE_BUTTON_FADE)
	_button_tween.finished.connect(_set_erase_disabled.bind(false))


func _fade_out_erase_button() -> void:
	if not erase_button.visible:
		return
	
	erase_button.disabled = true
	if is_instance_valid(_button_tween) and _button_tween.is_valid():
		_button_tween.kill()
	
	_button_tween = create_tween()
	_button_tween.tween_property(erase_button, ^"modulate", Color.TRANSPARENT, ERASE_BUTTON_FADE)
	_button_tween.finished.connect(_set_erase_button_visible.bind(false))


func _on_erase_button_pressed() -> void:
	if not is_table_active or active_cards.is_empty():
		return
	
	var focused_idx: int = roundi(target_scroll)
	if focused_idx < 0 or active_cards.size() <= focused_idx:
		return
	
	var target_card: TagItProjectCard = active_cards[focused_idx]
	project_erase_requested.emit(target_card.project_id, target_card)


func erase_card(card: TagItProjectCard) -> void:
	var active_idx: int = active_cards.find(card)
	if active_idx == -1:
		return
	
	_is_center_settled = false
	_table_active = true
	_fade_out_erase_button()
	
	all_cards.erase(card)
	active_cards.remove_at(active_idx)
	
	card.z_index = 60
	var lift_target_y: float = card.position.y - ERASE_LIFT_DISTANCE * _height_ratio
	var pickup_tween: Tween = create_tween().set_parallel(true)
	pickup_tween.tween_property(card, ^"position:y", lift_target_y, ERASE_ANIM_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pickup_tween.tween_property(card, ^"scale", card.scale * 1.08, ERASE_ANIM_DURATION).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	pickup_tween.tween_property(card, ^"modulate:a", 0.0, ERASE_ANIM_DURATION).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await pickup_tween.finished
	card.queue_free()
	
	_on_active_cards_size_changed()
	if not active_cards.is_empty():
		if active_idx < roundi(scroll_progress):
			scroll_progress = maxf(scroll_progress - 1.0, 0.0)
		target_scroll = clampf(float(active_idx), 0.0, float(active_cards.size() - 1))
		_table_active = true
		_fade_in_erase_button()
	else:
		scroll_progress = 0.0
		target_scroll = 0.0


func _on_card_selected(card: TagItProjectCard) -> void:
	if not is_table_active:
		return
	
	var idx: int = active_cards.find(card)
	if idx == -1:
		return
	
	if not is_equal_approx(target_scroll, float(idx)):
		await _focus_card_at_index(idx)
		return
	
	_table_active = false
	search_bar.editable = false
	
	scroll_progress = float(idx)
	_evaluate_active_curve()
	
	await _recall_all_to_right_pile(card)
	await _fade_search()
	project_load_requested.emit(card.project_id, card)


func _on_left_deck_pressed() -> void:
	if not is_table_active or active_cards.is_empty():
		return
	
	var half_span: float = 0.5 / _dynamic_spacing_t
	var top_left_idx: int = int(floorf(scroll_progress - half_span))
	_focus_card_at_index(top_left_idx)


func _on_right_deck_pressed() -> void:
	if not is_table_active or active_cards.is_empty():
		return
	
	var half_span: float = 0.5 / _dynamic_spacing_t
	var top_right_idx: int = int(ceilf(scroll_progress + half_span))
	_focus_card_at_index(top_right_idx)


func _focus_card_at_index(idx: int) -> void:
	if not is_table_active or idx < 0 or active_cards.size() <= idx:
		return
	
	var processing_input: bool = is_processing_input()
	if processing_input:
		set_process_input(false)
	
	var focus_tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	focus_tween.tween_property(self, ^"target_scroll", float(idx), FOCUS_DURATION)
	await focus_tween.finished
	if processing_input:
		set_process_input(true)


func _setup_search_timer() -> void:
	search_timer = Timer.new()
	search_timer.one_shot = true
	search_timer.wait_time = SEARCH_DEBOUNCE_TIME
	search_timer.timeout.connect(_on_search_debounce_finished)
	add_child(search_timer)
	search_bar.text_changed.connect(_on_search_text_changed)


func _get_offscreen_right_x() -> float:
	return size.x + CARD_SIZE.x * _dynamic_deck_scale


func _slide_deck_in() -> void:
	_table_active = false
	if all_cards.is_empty():
		return
	
	var offscreen_x: float = _get_offscreen_right_x()
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
	
	for i: int in range(all_cards.size()):
		var card: TagItProjectCard = all_cards[i]
		var stack_offset: Vector2 = _dynamic_stack_offset * float(i)
		card.position = Vector2(offscreen_x, _dynamic_base_y) + stack_offset
		card.scale = Vector2.ONE * _dynamic_deck_scale
		card.rotation = card.pile_rotation
		card.z_index = all_cards.size() - i
		
		var target_pos: Vector2 = Vector2(_right_pile_x, _dynamic_base_y) + stack_offset
		tween.tween_property(card, "position", target_pos, SLIDE_DURATION)
	
	await tween.finished


func _slide_deck_out(ignored_card: TagItProjectCard = null) -> void:
	await _recall_all_to_right_pile(ignored_card)
	if all_cards.is_empty():
		return
	
	var offscreen_x: float = _get_offscreen_right_x()
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var has_tweens: bool = false
	
	var stack_idx: int = 0
	for i: int in all_cards.size():
		var card: TagItProjectCard = all_cards[i]
		if card == ignored_card:
			continue
		has_tweens = true
		var target_pos: Vector2 = Vector2(offscreen_x, _dynamic_base_y) + _dynamic_stack_offset * float(stack_idx)
		tween.tween_property(card, "position", target_pos, SLIDE_DURATION)
		stack_idx += 1
	
	if has_tweens:
		await tween.finished
	else:
		tween.kill()


func _recall_all_to_right_pile(ignored_card: TagItProjectCard = null) -> void:
	_table_active = false
	_is_recalling = true
	
	if all_cards.is_empty():
		_is_recalling = false
		return
	
	var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	var stack_idx: int = 0
	var has_tweens: bool = false
	
	for i: int in all_cards.size():
		var card: TagItProjectCard = all_cards[i]
		card.button_visible = false
		
		if card == ignored_card:
			card.z_index = 50
			continue
		
		has_tweens = true
		card.z_index = all_cards.size() - stack_idx
		var target_pos: Vector2 = Vector2(_right_pile_x, _dynamic_base_y) + _dynamic_stack_offset * float(stack_idx)
		tween.tween_property(card, "position", target_pos, RECALL_TIME)
		tween.tween_property(card, "scale", Vector2.ONE * _dynamic_deck_scale, RECALL_TIME)
		tween.tween_property(card, "rotation", card.pile_rotation, RECALL_TIME)
		stack_idx += 1
	
	if has_tweens:
		await tween.finished
	else:
		tween.kill()
	_is_recalling = false


func _deal_initial_cards() -> void:
	_is_center_settled = true
	_table_active = true
	_fade_in_erase_button()
	_gui_active = 1 < active_cards.size()
	if active_cards.is_empty():
		return
	
	var half_span: float = 0.5 / _dynamic_spacing_t
	scroll_progress = -half_span
	target_scroll = 0.0
	_evaluate_active_curve()
	
	var deal_tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	deal_tween.tween_method(_on_deal_step, -half_span, 0.0, DEAL_DURATION)
	await deal_tween.finished
	
	_table_active = true
	_fade_in_erase_button()


func _on_deal_step(value: float) -> void:
	scroll_progress = value
	_evaluate_active_curve()


func _on_active_cards_size_changed() -> void:
	_table_empty = active_cards.is_empty()


func _process(delta: float) -> void:
	scroll_progress = lerpf(scroll_progress, target_scroll, clampf(delta * SMOOTH_SPEED, 0.0, 1.0))
	_evaluate_active_curve()
	
	var nearest_idx: float = roundf(target_scroll)
	var is_centered_now: bool = is_equal_approx(target_scroll, nearest_idx) and absf(scroll_progress - nearest_idx) <= CENTER_SNAP_TOLERANCE
	if is_centered_now != _is_center_settled:
		_is_center_settled = is_centered_now
		if _is_center_settled:
			_fade_in_erase_button()
		else:
			_fade_out_erase_button()


func _gui_input(event: InputEvent) -> void:
	if not is_table_active or not _gui_active:
		return
	if event is InputEventMouseButton and event.pressed:
		var new_target: float = target_scroll
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_target = clampf(target_scroll + SCROLL_SPEED, 0.0, float(active_cards.size() - 1))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_target = clampf(target_scroll - SCROLL_SPEED, 0.0, float(active_cards.size() - 1))
		
		if not is_equal_approx(new_target, target_scroll):
			target_scroll = new_target


func _evaluate_active_curve() -> void:
	var half_span: float = 0.5 / _dynamic_spacing_t
	
	for i: int in range(active_cards.size()):
		var card: TagItProjectCard = active_cards[i]
		var t: float = clampf(0.5 + (scroll_progress - float(i)) * _dynamic_spacing_t, 0.0, 1.0)
		
		if t <= 0.0:
			card.button_visible = false
			var depth: int = maxi(i - int(ceilf(scroll_progress + half_span)), 0)
			card.position = Vector2(_right_pile_x, _dynamic_base_y) + _dynamic_stack_offset * float(depth)
			card.scale = Vector2.ONE * _dynamic_deck_scale
			card.rotation = card.pile_rotation
			card.z_index = 15 - mini(depth, 14)
		elif t >= 1.0:
			card.button_visible = false
			var depth: int = maxi(int(floorf(scroll_progress - half_span)) - i, 0)
			card.position = Vector2(_left_pile_x, _dynamic_base_y) + _dynamic_stack_offset * float(depth)
			card.scale = Vector2.ONE * _dynamic_deck_scale
			card.rotation = card.pile_rotation
			card.z_index = 15 - mini(depth, 14)
		else:
			card.button_visible = true
			var pos_x: float = lerpf(_right_pile_x, _left_pile_x, t)
			var center_factor: float = 1.0 - absf(t - 0.5) * 2.0
			var scale_val: float = lerpf(_dynamic_deck_scale, _dynamic_center_scale, center_factor)
			var edge_blend: float = clampf(center_factor * 4.0, 0.0, 1.0)
			
			card.position = Vector2(pos_x, _dynamic_base_y)
			card.scale = Vector2.ONE * scale_val
			card.rotation = lerpf(card.pile_rotation, 0.0, edge_blend)
			card.z_index = 20 + int(center_factor * 20.0)


func _on_search_text_changed(_new_text: String) -> void:
	search_timer.start()
	_is_center_settled = false
	_fade_out_erase_button()
	if not _is_recalling:
		_recall_all_to_right_pile()


func _on_search_debounce_finished() -> void:
	var query: String = search_bar.text.strip_edges().to_lower()
	active_cards.clear()
	side_cards.clear()
	
	if query.is_empty():
		active_cards = all_cards.duplicate()
	else:
		for card: TagItProjectCard in all_cards:
			var title: String = card.get_card_title()
			var description: String = card.get_card_description()
			if query.is_empty() or title.containsn(query) or description.containsn(query):
				active_cards.append(card)
			else:
				side_cards.append(card)
	
	if 0 < side_cards.size():
		var tween := create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		for i: int in range(side_cards.size()):
			var card: TagItProjectCard = side_cards[i]
			card.z_index = 5 - mini(i, 4)
			var side_pos: Vector2 = Vector2(_right_pile_x + 25.0 * _height_ratio, _dynamic_side_deck_y) + _dynamic_stack_offset * float(i)
			tween.tween_property(card, "position", side_pos, 0.25)
			tween.tween_property(card, "scale", Vector2.ONE * (_dynamic_deck_scale * 0.82), 0.25)
			tween.tween_property(card, "rotation", card.pile_rotation, 0.25)
	
	_on_active_cards_size_changed()
	_deal_initial_cards()
