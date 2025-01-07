extends PanelContainer

signal close_pressed
signal card_selected(card_index: int)
signal card_deleted(card_index: int)
signal card_saved(card_title: String)
signal intro_finished
signal outro_finished
signal cards_displayed

const CARD_CONTAINER = preload("res://scenes/card_container.tscn")
@export_range(0.05, 1.0, 0.01, "or_greater") var section_in_time: float = 1.0
@export_range(0.05, 1.0, 0.01, "or_greater") var section_out_time: float = 1.0
@export_range(0.05, 1.0, 0.01, "or_greater") var card_fade_time: float = 0.75
@export var use_search: bool = true
@export var use_close: bool = true
@export var editable_cards: bool = false
@export var use_save: bool = false
@export var dim_background: bool = false
var focused_child: Control = null
var use_descriptions: bool = true
var _allow_signals: bool = true
@onready var container: Container = $VBoxContainer/PanelContainer/MarginContainer/SmoothScrollContainer/CenterContainer/Container
@onready var margin: MarginContainer = $VBoxContainer/PanelContainer/MarginContainer
@onready var black: PanelContainer = $VBoxContainer/PanelContainer
@onready var close_button: Button = $VBoxContainer/HBoxContainer/CloseButton
@onready var search_ln_edt: LineEdit = $VBoxContainer/CenterContainer/SearchPanel/SearchLnEdt
@onready var dim_light: ColorRect = $DimLight
@onready var search_panel: PanelContainer = $VBoxContainer/CenterContainer/SearchPanel
@onready var scroller: SmoothScrollContainer = $VBoxContainer/PanelContainer/MarginContainer/SmoothScrollContainer



func _ready() -> void:
	_allow_signals = false
	close_button.visible = false
	margin.visible = false
	#search_ln_edt.visible = false
	search_panel.visible = false
	dim_light.visible = false
	black.size_flags_stretch_ratio = 0.0
	container.cards_displayed.connect(on_cards_displayed)
	close_button.pressed.connect(close_pressed.emit)
	search_ln_edt.text_submitted.connect(on_search_text_submitted)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel") and _allow_signals:
		close_pressed.emit()
		get_viewport().set_input_as_handled()


func on_cards_displayed() -> void:
	cards_displayed.emit()


func set_emit_signals(emit_signals: bool) -> void:
	_allow_signals = emit_signals


func emits_signals() -> bool:
	return _allow_signals


func on_search_text_submitted(new_text: String) -> void:
	container.search_children(new_text.strip_edges())


func stop_queued_cards() -> void:
	container.stop_queue()


func create_cards(card_data: Array[Dictionary]) -> void:
	for card_dict in card_data:
		var new_card := CARD_CONTAINER.instantiate()
		new_card.title = card_dict["title"]
		new_card.description = card_dict["description"]
		new_card.image = card_dict["image"]
		new_card.show_description = use_descriptions
		new_card.editable = editable_cards
		new_card.use_save = use_save
		new_card.card_selected.connect(on_card_selected.bind(new_card))
		new_card.card_confirmed.connect(on_card_confirmed.bind(new_card))
		new_card.card_deleted.connect(on_card_deleted.bind(new_card))
		new_card.card_saved.connect(on_card_saved)
		new_card.card_cancelled.connect(on_card_cancelled)
		container.queue_child_entry(new_card)
	container.enter_children()


func queue_card(title: String, description: String, image: Texture2D) -> void:
	var new_card := CARD_CONTAINER.instantiate()
	new_card.title = title
	new_card.description = description
	new_card.image = image
	new_card.show_description = use_descriptions
	new_card.editable = editable_cards
	new_card.use_save = use_save
	new_card.card_selected.connect(on_card_selected.bind(new_card))
	new_card.card_confirmed.connect(on_card_confirmed.bind(new_card))
	new_card.card_deleted.connect(on_card_deleted.bind(new_card))
	new_card.card_saved.connect(on_card_saved)
	new_card.card_cancelled.connect(on_card_cancelled)
	container.queue_child_entry(new_card)


func on_card_cancelled() -> void:
	if not _allow_signals:
		return
	close_pressed.emit()


func on_card_saved(title: String) -> void:
	if not _allow_signals:
		return
	card_saved.emit(title)


func create_queued_cards() -> void:
	container.enter_children()


func play_intro() -> void:
	if dim_background:
		dim_light.visible = true
		dim_light.modulate = Color.TRANSPARENT
	var opening_tween: Tween = create_tween()
	opening_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	opening_tween.tween_property(black, ^"size_flags_stretch_ratio", 10, section_in_time)
	if dim_background:
		opening_tween.parallel().tween_property(dim_light, ^"modulate", Color.WHITE, section_in_time)
	await opening_tween.finished
	if use_search:
		search_panel.visible = true
	if use_close:
		close_button.visible = true
	margin.visible = true
	intro_finished.emit()


func play_outro() -> void:
	if use_close:
		close_button.visible = false
	if use_search:
		search_panel.visible = false
	
	var card_tween: Tween = create_tween()
	card_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	await card_tween.tween_property(margin, ^"modulate", Color.TRANSPARENT, card_fade_time).finished
	margin.visible = false
	margin.modulate = Color.WHITE
	var close_tween: Tween = create_tween()
	close_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	close_tween.tween_property(black, ^"size_flags_stretch_ratio", 0, section_out_time)
	if dim_background:
		close_tween.parallel().tween_property(dim_light, ^"modulate", Color.TRANSPARENT, section_out_time)
	await close_tween.finished
	outro_finished.emit()


func on_card_selected(card: Control) -> void:
	if focused_child != null:
		container.unfocus_child(focused_child)
	focused_child = card
	container.focus_child(card)
	var container_rect := card.get_global_rect()
	var viewport := margin.get_global_rect()#get_viewport_rect()
	var scroll_offset: Vector2 = Vector2.ZERO
	#scroller.ensure_control_visible(card)
	if not viewport.encloses(container_rect):
		if container.alignment == 0: # Horizontal:
			if container_rect.position.x < 0:
				scroll_offset.x = container_rect.position.x - container.child_separation - margin.get_theme_constant("margin_left") - container.child_separation
			elif container_rect.position.x + container_rect.size.x > viewport.size.x:
				scroll_offset.x = container_rect.position.x + container_rect.size.x - viewport.size.x + margin.get_theme_constant("margin_right") + container.child_separation
			scroller.scroll_x_to(-(scroller.scroll_horizontal + scroll_offset.x), 0.50)
		else:
			if container_rect.position.y < 0:
				scroll_offset.y = container_rect.position.y  # Scroll up
			elif container_rect.position.y + container_rect.size.y > viewport.size.y:
				scroll_offset.y = container_rect.position.y + container_rect.size.y - viewport.size.y  # Scroll down
			scroller.scroll_y_to(-(scroller.scroll_vertical + scroll_offset.y))


func on_card_confirmed(card: Control) -> void:
	if _allow_signals:
		card_selected.emit(card.get_index())


func on_card_deleted(card: Control) -> void:
	var acrd_idx: int = card.get_index()
	container.drop_card(card)
	container.reorder_children()
	focused_child = null
	if _allow_signals:
		card_deleted.emit(acrd_idx)


func create_card_dictionary(title: String, description: String, image: Texture2D) -> Dictionary:
	return {"title": title, "description": description, "image": image}
