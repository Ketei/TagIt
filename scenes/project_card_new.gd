class_name TagItProjectCard
extends PanelContainer


signal card_selected(card: PanelContainer)

const CONTENT_MARGINS: float = 7.0
const DESCRIPTION_MARGIN: float = 40.0
const CARD_SIZE: Vector2 = Vector2(350.0, 480.0)

var pile_rotation: float = 0.0

var _card_texture: TextureRect
var _data_container: Control
var _backdrop: ColorRect

var _title_container: PanelContainer
var _title_label: Label
var _title_editor: LineEdit

var _description_container: PanelContainer
var _description_label: RichTextLabel
var _description_editor: TextEdit

var _card_select_btn: Button

var project_id: String = ""

var button_visible: bool = true:
	set(v):
		button_visible = v
		_card_select_btn.visible = v

var edit_mode: bool = false:
	set(e):
		if e == edit_mode:
			return
		
		edit_mode = e
		_card_select_btn.visible = not e
		if e:
			_title_label.visible = false
			_description_label.visible = false
			
			_title_editor.visible = true
			_description_editor.visible = true
			_title_container.visible = true
			_description_container.visible = true
		else:
			_title_label.visible = true
			_description_label.visible = true
			_title_editor.visible = false
			_description_editor.visible = false
			_title_container.visible = not _title_label.text.is_empty()
			_description_container.visible = not _title_editor.text.is_empty()


func _init(card_edit: bool = false, texture: ImageTexture = null, title: String = "", description: String = "") -> void:
	var image_container: PanelContainer = PanelContainer.new()
	_backdrop = ColorRect.new()
	var panel: StyleBoxFlat = preload("res://scenes/card_style_box.tres").duplicate()
	#panel.border_color = Color.from_hsv(randf(), 0.65, 0.90)
	size = CARD_SIZE
	add_theme_stylebox_override(&"panel", panel.duplicate())
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	pivot_offset = CARD_SIZE * 0.5
	
	_card_texture = TextureRect.new()
	_data_container = Control.new()
	
	_title_container = PanelContainer.new()
	_title_label = Label.new()
	_title_editor = LineEdit.new()
	
	_description_container = PanelContainer.new()
	_description_label = RichTextLabel.new()
	_description_editor = TextEdit.new()
	
	_card_select_btn = Button.new()
	
	image_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	image_container.show_behind_parent = true
	_backdrop.color = Color(0.125, 0.145, 0.251)
	
	_data_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_card_texture.name = "CardTexture"
	_data_container.name = "DataContainer"
	_title_container.name = "TitleContainer"
	_title_label.name = "TitleLabel"
	_title_editor.name = "TitleEditor"
	_description_container.name = "DescriptionContainer"
	_description_label.name = "DescriptionLabel"
	_description_editor.name = "DescriptionEditor"
	_card_select_btn.name = "CardSelectBtn"
	
	_card_texture.texture = texture
	_card_texture.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_card_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_card_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	_title_container.position.x = DESCRIPTION_MARGIN
	_title_container.position.y = (CARD_SIZE.y / 3.0) * 2.0
	_title_container.size.x = CARD_SIZE.x - (DESCRIPTION_MARGIN * 2)
	_title_container.size.y = 48.0
	_title_container.add_theme_stylebox_override(&"panel", preload("res://scenes/card_title_style.tres"))
	
	_description_container.position.y = _title_container.position.y + _title_container.size.y + 8
	_description_container.size.x = CARD_SIZE.x - (CONTENT_MARGINS * 2)
	_description_container.size.y = ((CARD_SIZE.y - (CONTENT_MARGINS * 2)) - _description_container.position.y) / 3 * 2
	_description_container.add_theme_stylebox_override(&"panel", preload("res://scenes/card_description_style.tres"))
	
	_title_label.text = title
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title_label.clip_text = true
	_title_label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	_title_label.size_flags_vertical = Control.SIZE_FILL
	
	_title_editor.text = title
	_title_editor.placeholder_text = "Card Title"
	_title_editor.alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_editor.flat = true
	_title_editor.caret_blink = true
	_title_editor.add_theme_stylebox_override(&"focus", StyleBoxEmpty.new())
	
	_description_label.text = description
	_description_label.bbcode_enabled = true
	
	var empty: StyleBoxEmpty = StyleBoxEmpty.new()
	_description_editor.text = description
	_description_editor.placeholder_text = "Card Description"
	_description_editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	_description_editor.add_theme_stylebox_override(&"normal", empty)
	_description_editor.add_theme_stylebox_override(&"focus", empty)
	_description_editor.add_theme_stylebox_override(&"read_only", empty)
	
	_card_select_btn.flat = true
	_card_select_btn.focus_mode = Control.FOCUS_NONE
	_card_select_btn.mouse_filter = Control.MOUSE_FILTER_PASS
	
	if not card_edit:
		_title_label.visible = true
		_description_label.visible = true
		_title_editor.visible = false
		_description_editor.visible = false
		_title_container.visible = not title.is_empty()
		_description_container.visible = not description.is_empty()
	else:
		edit_mode = card_edit
	
	_title_container.add_child(_title_label)
	_title_container.add_child(_title_editor)
	
	_description_container.add_child(_description_label)
	_description_container.add_child(_description_editor)
	
	_data_container.add_child(_title_container)
	_data_container.add_child(_description_container)
	
	image_container.add_child(_backdrop)
	image_container.add_child(_card_texture)
	
	add_child(image_container)
	add_child(_data_container)
	add_child(_card_select_btn)


func _ready() -> void:
	_title_editor.focus_next = _description_editor.get_path()
	_description_editor.focus_previous = _title_editor.get_path()
	
	_card_select_btn.pressed.connect(_on_card_selected)


func focus_title(caret_to_end: bool = true, select_all: bool = true) -> void:
	if not edit_mode:
		return
	
	_title_editor.grab_focus(true)
	if select_all:
		_title_editor.select_all()
	if caret_to_end:
		_title_editor.caret_column = _title_editor.text.length()


func focus_description(caret_to_end: bool = true) -> void:
	if not edit_mode:
		return
	
	_description_editor.grab_focus(true)
	if caret_to_end:
		var last_line: int = _description_editor.get_line_count() - 1
		var last_column: int = _description_editor.get_line(last_line).length()
		_description_editor.set_caret_line(last_line)
		_description_editor.set_caret_column(last_column)


func get_card_title() -> String:
	if edit_mode:
		return _title_editor.text.strip_edges()
	else:
		return _title_label.text


func set_card_title(title: String) -> void:
	_title_label.text = title
	_title_editor.text = title
	if not edit_mode:
		_title_container.visible = not title.is_empty()


func get_card_description() -> String:
	if edit_mode:
		return _description_editor.text.strip_edges()
	else:
		return _description_label.text


func set_card_description(description: String) -> void:
	_description_label.text = description
	_description_editor.text = description
	if not edit_mode:
		_description_container.visible = not description.is_empty()


func set_card_texture(texture: Texture2D) -> void:
	_card_texture.texture = texture


func set_card_border_color(color: Color) -> void:
	var panel: StyleBoxFlat = get_theme_stylebox(&"panel")
	panel.border_color = color


func _on_card_selected() -> void:
	card_selected.emit(self)
