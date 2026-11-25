extends PanelContainer


signal load_next_image(current: int)
signal load_previous_image(current: int)

enum MediaStatus {
	STOPPED,
	PAUSED,
	PLAYING
}

enum MediaType {
	NONE,
	IMAGE,
	GIF,
}

var image_type: MediaType = MediaType.NONE:
	set(i):
		image_type = i
		var vid: bool = i == MediaType.GIF
		playback_controls.visible = vid
		gif_player.visible = vid
		image_rect.visible = i == MediaType.IMAGE
		viewer_container.visible = image_type != MediaType.NONE

var playback_status: MediaStatus = MediaStatus.STOPPED:
	set(p):
		playback_status = p
		if p != MediaStatus.PLAYING:
			play_pause_btn.icon = preload("uid://bwrwxwuiprvbp")
		else:
			play_pause_btn.icon = preload("uid://bhjabr4vq7pc6")

#var _image_frames: SpriteFrames = null
var current_frame: int = 0
var frame_count: int = 0
var image_index: int = -1
var _spinner_tween: Tween

@onready var image_rect: TextureRect = $ViewerContainer/VBoxContainer/ScrollZoomView/Control/TextureRect
@onready var gif_player: GifTextureRect = $ViewerContainer/VBoxContainer/ScrollZoomView/Control/GifTextureRect
#@onready var delta_timer: Node = $DeltaTimer
@onready var throbber: TextureProgressBar = $ThrobberContainer/Throbber
@onready var image_viewer: ScrollZoomView = $ViewerContainer/VBoxContainer/ScrollZoomView
@onready var throbber_container: MarginContainer = $ThrobberContainer
@onready var viewer_container: PanelContainer = $ViewerContainer
@onready var wiki_search_ln_edt: LineEdit = $WikiMargin/WikiContainer/WikiInfoContainer/SearchContainer/WikiSearchLnEdt
@onready var wiki_scroll_ctnr: ScrollContainer = $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/WikiScrollCtnr
@onready var parents_scroll_container: ScrollContainer = $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/ParentsContainer/DataContainer/ScrollContainer
@onready var aliases_scroll_container: ScrollContainer = $WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/AliasesContainer/DataContainer/ScrollContainer
@onready var reload_images_button: Button = $WikiMargin/WikiContainer/ImageContainer/WikiDets/ReloadImagesButton
@onready var thumbnails_scroll_container: ScrollContainer = $WikiMargin/WikiContainer/ImageContainer/ScrollContainer

@onready var playback_controls: HBoxContainer = $ViewerContainer/VBoxContainer/PlaybackControls
@onready var play_pause_btn: Button = $ViewerContainer/VBoxContainer/PlaybackControls/PlayPauseBtn
@onready var stop_btn: Button = $ViewerContainer/VBoxContainer/PlaybackControls/StopBtn


func _ready() -> void:
	if visible:
		visible = false
	var wiki_scroll: VScrollBar = wiki_scroll_ctnr.get_v_scroll_bar()
	var parent_scroll: HScrollBar = parents_scroll_container.get_h_scroll_bar()
	var alias_scroll: HScrollBar = aliases_scroll_container.get_h_scroll_bar()
	
	set_process_input(false)
	
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
	
	play_pause_btn.pressed.connect(_on_play_pressed)
	stop_btn.pressed.connect(_on_stop_pressed)
	visibility_changed.connect(_on_visibility_changed)


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


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.echo or not event.pressed:
			return
		var _handled: bool = false
		
		if image_type != MediaType.NONE:
			if event.keycode == KEY_ESCAPE:
				if not throbber_container.visible:
					if image_type != MediaType.NONE:
						if image_type == MediaType.GIF:
							if playback_status != MediaStatus.STOPPED:
								gif_player.stop()
						image_type = MediaType.NONE
						image_index = -1
				_handled = true
			elif event.keycode == KEY_RIGHT:
				load_next_image.emit(image_index)
				_handled = true
			elif event.keycode == KEY_LEFT:
				load_previous_image.emit(image_index)
				_handled = true
		else:
			if event.keycode == KEY_F and event.ctrl_pressed and not event.shift_pressed:
				if not wiki_search_ln_edt.has_focus():
					wiki_search_ln_edt.grab_focus()
				wiki_search_ln_edt.select_all()
				wiki_search_ln_edt.caret_column = wiki_search_ln_edt.text.length()
				_handled = true
			else:
				if event.ctrl_pressed or event.alt_pressed:
					return
				
				var focused_node: Control = get_viewport().gui_get_focus_owner()
				if focused_node is LineEdit:
					if focused_node.is_editing():
						return
				elif focused_node is TextEdit:
					if focused_node.editable:
						return
				elif focused_node is Tree:
					if 0 < focused_node.get_root().get_child_count():
						return
				
				var printable: bool = 32 <= event.unicode and event.unicode != 127
				var deletion: bool = event.keycode == KEY_BACKSPACE or event.keycode == KEY_DELETE
				if printable or deletion:
					wiki_search_ln_edt.grab_focus()
					wiki_search_ln_edt.caret_column = wiki_search_ln_edt.text.length()
				
		if _handled:
			get_viewport().set_input_as_handled()


func set_static_image(img: Texture2D) -> void:
	image_viewer.reset_zoom()
	if image_type == MediaType.GIF:
		if playback_status != MediaStatus.STOPPED:
			gif_player.stop()
			playback_status = MediaStatus.STOPPED
		gif_player = null
	
	if throbber_container.visible:
		hide_throbber()
	
	if img == null:
		image_type = MediaType.NONE
		image_rect.texture = null
		return
	
	image_type = MediaType.IMAGE
	image_rect.texture = img


func set_gif(gif: SpriteFrames) -> void:
	image_viewer.reset_zoom()
	if image_type == MediaType.IMAGE:
		image_rect.texture = null
	
	if playback_status != MediaStatus.STOPPED:
		gif_player.stop()
		playback_status = MediaStatus.STOPPED
	
	if gif == null:
		gif_player.gif = null
		image_type = MediaType.NONE
		return
	
	image_type = MediaType.GIF
	gif_player.gif = gif
	playback_status = MediaStatus.PLAYING
	gif_player.play()
	
	if throbber_container.visible:
		hide_throbber()


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


func _on_play_pressed() -> void:
	match playback_status:
		MediaStatus.PLAYING: # Convert to pause
			playback_status = MediaStatus.PAUSED
			if image_type == MediaType.GIF:
				gif_player.paused = true
		MediaStatus.STOPPED:
			playback_status = MediaStatus.PLAYING
			if image_type == MediaType.GIF:
				if gif_player.paused:
					gif_player.paused = false
				gif_player.play()
		MediaStatus.PAUSED:
			if image_type == MediaType.GIF:
				playback_status = MediaStatus.PLAYING
				gif_player.paused = false


func _on_stop_pressed() -> void:
	if image_type == MediaType.GIF:
		gif_player.stop()
		playback_status = MediaStatus.STOPPED



func _on_visibility_changed() -> void:
	if is_visible_in_tree():
		set_process_input(true)
		if image_type == MediaType.GIF:
			if playback_status == MediaStatus.PLAYING and gif_player.paused:
				gif_player.paused = false
	else:
		set_process_input(false)
		if playback_status == MediaStatus.PLAYING:
				gif_player.paused = true
