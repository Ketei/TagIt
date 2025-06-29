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
@onready var throbber: TextureProgressBar = $ThrobberContainer/Throbber
@onready var image_viewer: ScrollZoomView = $ViewerContainer/ScrollZoomView
@onready var throbber_container: MarginContainer = $ThrobberContainer
@onready var viewer_container: PanelContainer = $ViewerContainer
@onready var wiki_search_ln_edt: LineEdit = $WikiMargin/WikiContainer/WikiInfoContainer/SearchContainer/WikiSearchLnEdt
@onready var wiki_scroll_ctnr: ScrollContainer = $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/WikiScrollCtnr
@onready var parents_scroll_container: ScrollContainer = $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/ParentsContainer/DataContainer/ScrollContainer
@onready var aliases_scroll_container: ScrollContainer = $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/AliasesContainer/DataContainer/ScrollContainer
@onready var reload_images_button: Button = $WikiMargin/WikiContainer/ImageContainer/WikiDets/ReloadImagesButton
@onready var thumbnails_scroll_container: ScrollContainer = $WikiMargin/WikiContainer/ImageContainer/ScrollContainer



func _ready() -> void:
	if visible:
		visible = false
	var wiki_scroll: VScrollBar = wiki_scroll_ctnr.get_v_scroll_bar()
	var parent_scroll: HScrollBar = parents_scroll_container.get_h_scroll_bar()
	var alias_scroll: HScrollBar = aliases_scroll_container.get_h_scroll_bar()
	
	viewer_container.visible = false
	throbber_container.visible = false
	wiki_scroll.custom_step = 23
	parent_scroll.custom_step = 23
	alias_scroll.custom_step = 23
	wiki_scroll.focus_neighbor_top = wiki_scroll.get_path()
	wiki_scroll.focus_neighbor_bottom = wiki_scroll.get_path()
	parent_scroll.focus_neighbor_left = parent_scroll.get_path()
	parent_scroll.focus_neighbor_right = parent_scroll.get_path()
	alias_scroll.focus_neighbor_left = alias_scroll.get_path()
	alias_scroll.focus_neighbor_right = alias_scroll.get_path()
	wiki_scroll.focus_previous = $"../MenuMargin/MenuContainer/TabBar".get_path()
	
	delta_timer.advance_frames.connect(on_advance_frame)


func update_focus() -> void:
	await get_tree().process_frame
	var wiki_scroll: VScrollBar = wiki_scroll_ctnr.get_v_scroll_bar()
	var parent_scroll: HScrollBar = parents_scroll_container.get_h_scroll_bar()
	var alias_scroll: HScrollBar = aliases_scroll_container.get_h_scroll_bar()
	
	var parent_active: bool = parent_scroll.visible and $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/ParentsContainer.visible
	var alias_active: bool = alias_scroll.visible and $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/AliasesContainer.visible
	var wiki_active: bool = wiki_scroll.visible
	
	wiki_scroll.focus_mode = Control.FOCUS_ALL if wiki_active else Control.FOCUS_NONE
	parent_scroll.focus_mode = Control.FOCUS_ALL if parent_active else Control.FOCUS_NONE
	alias_scroll.focus_mode = Control.FOCUS_ALL if alias_active else Control.FOCUS_NONE
	
	if parent_active:
		wiki_scroll.focus_next = parent_scroll.get_path()
		parent_scroll.focus_previous = wiki_scroll.get_path() if wiki_active else $"../MenuMargin/MenuContainer/TabBar".get_path()
		parent_scroll.focus_next = alias_scroll.get_path() if alias_active else wiki_search_ln_edt.get_path()
	elif alias_active:
		wiki_scroll.focus_next = alias_scroll.get_path()
		alias_scroll.focus_previous = wiki_scroll.get_path() if wiki_active else $"../MenuMargin/MenuContainer/TabBar".get_path()
		aliases_scroll_container.focus_next = wiki_search_ln_edt.get_path()
	else:
		wiki_scroll.focus_next = wiki_search_ln_edt.get_path()
	
	if alias_active:
		wiki_search_ln_edt.focus_previous = alias_scroll.get_path()
	elif parent_active:
		wiki_search_ln_edt.focus_previous = parent_scroll.get_path()
	elif wiki_active:
		wiki_search_ln_edt.focus_previous = wiki_scroll.get_path()
	else:
		wiki_search_ln_edt.focus_previous = $"../MenuMargin/MenuContainer/TabBar".get_path()


func process_input(event: InputEvent) -> void:
	var _handled: bool = false
	if texture_rect.is_visible_in_tree():
		if event.is_action_pressed(&"ui_cancel"):
			if not throbber_container.visible:
				viewer_container.visible = false
				if delta_timer.timer_running():
					delta_timer.stop_timer()
				image_index = -1
			_handled = true
		elif event.is_action_pressed(&"ui_right"):
			load_next_image.emit(image_index)
			_handled = true
		elif event.is_action_pressed(&"ui_left"):
			load_previous_image.emit(image_index)
			_handled = true
	else:
		if event.is_pressed():
			if event.keycode == KEY_F and event.ctrl_pressed:
				if not wiki_search_ln_edt.has_focus():
					wiki_search_ln_edt.grab_focus()
				wiki_search_ln_edt.select_all()
				wiki_search_ln_edt.caret_column = wiki_search_ln_edt.text.length()
				_handled = true
			else:
				var valid_range: bool = Math.is_betweeni(event.keycode, 4194433, 4194447) or Math.is_betweeni(event.keycode, 33, 96) or Math.is_betweeni(event.keycode, 123, 126)
				if valid_range and not event.ctrl_pressed and not event.alt_pressed:
					wiki_search_ln_edt.grab_focus()
					wiki_search_ln_edt.caret_column = wiki_search_ln_edt.text.length()
					
	if _handled:
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
