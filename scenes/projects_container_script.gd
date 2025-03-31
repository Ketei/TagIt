class_name ProjectSelector
extends Control


signal close_pressed
signal card_selected(card_uuid: String)
signal card_deleted(card_uuid: String)
signal card_saved(card_title: String)
signal save_finished(success: bool, title: String)
signal intro_finished
signal outro_finished

const CARD_CONTAINER = preload("res://scenes/card_container.tscn")
const FULL_CARD_CONTAINER = preload("res://scenes/full_card_container.tscn")

@export var editable_cards: bool = false
@export var use_save: bool = false
@export_range(0.05, 1.0, 0.01, "or_greater") var focus_time: float = 0.25
@export_range(0.05, 1.0, 0.01, "or_greater") var section_in_time: float = 1.0
@export_range(0.05, 1.0, 0.01, "or_greater") var section_out_time: float = 0.5
@export_range(0.05, 1.0, 0.01, "or_greater") var card_fade_time: float = 0.40
@export var use_search: bool = true
@export var use_close: bool = true
var use_descriptions: bool = true
var group_save_enabled: bool = false
var _allow_signals: bool = true
var selected_card: ProjectCard = null
var allow_card_signals: bool = true
@export var dim_background: bool = false

#@onready var panel_container: PanelContainer = $PanelContainer
@onready var smooth_scroll_container: SmoothScrollContainer = $ProjectsContainer/MainPanel/MainMargin/CardsScroll
#@onready var h_box_container: Control = $PanelContainer/MarginContainer/SmoothScrollContainer/MarginContainer/HBoxContainer
@onready var cards_container: HBoxContainer = $ProjectsContainer/MainPanel/MainMargin/CardsScroll/CardsMargin/CardsContainer
@onready var close_button: Button = $ProjectsContainer/HeaderContainer/CloseButton
@onready var search_ln_edt: LineEdit = $ProjectsContainer/CenterContainer/SearchPanel/SearchLnEdt
@onready var main_margin: MarginContainer = $ProjectsContainer/MainPanel/MainMargin
@onready var search_panel: PanelContainer = $ProjectsContainer/CenterContainer/SearchPanel
@onready var dim_light: ColorRect = $DimLight
@onready var main_panel: PanelContainer = $ProjectsContainer/MainPanel


func _ready() -> void:
	_allow_signals = false
	close_button.visible = false
	main_margin.visible = false
	search_panel.visible = false
	dim_light.visible = false
	main_panel.size_flags_stretch_ratio = 0.0
	close_button.pressed.connect(_on_close_pressed)
	search_ln_edt.text_submitted.connect(_on_search_text_submitted)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel") and _allow_signals:
		close_pressed.emit()
		if group_save_enabled:
			save_finished.emit(false, "")
		get_viewport().set_input_as_handled()
	elif Input.is_action_just_pressed(&"ui_focus_next") and not search_ln_edt.has_focus():
		search_ln_edt.grab_focus()
		get_viewport().set_input_as_handled()


func _on_search_text_submitted(new_text: String) -> void:
	var search_text: String = new_text.strip_edges()
	var empty: bool = search_text.is_empty()
	
	for child:CardContainer in cards_container.get_children():
		child.visible = empty or child.card.title.containsn(search_text)


func _on_close_pressed() -> void:
	close_pressed.emit()
	if group_save_enabled:
		save_finished.emit(false, "")


func focus_main() -> void:
	search_ln_edt.grab_focus()


func add_project(title: String, description: String, image: Texture2D, project_uuid: String, grab_focus_field: int = -1) -> void:
	var card_container: CardContainer = CardContainer.new()
	var new_card := CARD_CONTAINER.instantiate()
	new_card.title = title
	new_card.description = description
	new_card.image = image
	new_card.show_description = use_descriptions
	new_card.editable = editable_cards
	new_card.use_save = use_save
	new_card.project_uuid = project_uuid
	new_card.grab_focus_field = grab_focus_field
	new_card.card_selected.connect(_on_card_selected)
	new_card.card_confirmed.connect(_on_card_confirmed)
	new_card.card_deleted.connect(_on_card_deleted)
	new_card.card_saved.connect(_on_card_saved)
	new_card.card_cancelled.connect(_on_card_cancelled)
	if group_save_enabled:
			new_card.card_saved.connect(operation_grouping.bind(true))
			new_card.card_cancelled.connect(operation_grouping.bind("", false))
	card_container.card = new_card
	cards_container.add_child(card_container)


func operation_grouping(title: String, success: bool):
	save_finished.emit(success, title)


func _on_card_cancelled(_title: String) -> void:
	if not _allow_signals:
		return
	close_pressed.emit()


func _on_card_saved(title: String) -> void:
	if not _allow_signals:
		return
	card_saved.emit(title)


func _on_card_deleted(card: CardContainer) -> void:
	var card_uuid: String = card.card.project_uuid
	card.queue_free()
	if _allow_signals:
		card_deleted.emit(card_uuid)


func _on_card_confirmed(card: ProjectCard) -> void:
	if _allow_signals:
		card_selected.emit(card.project_uuid)


func _on_card_selected(card: ProjectCard) -> void:
	if selected_card != null:
		selected_card.set_focus_enabled(false)
		selected_card.hide_buttons(focus_time)
	selected_card = card
	selected_card.set_focus_enabled(true)
	selected_card.focus_card_button()
	card.show_buttons(focus_time)
	


func play_intro() -> void:
	main_margin.modulate = Color.TRANSPARENT
	main_panel.modulate = Color.TRANSPARENT
	if dim_background:
		dim_light.visible = true
		dim_light.modulate = Color.TRANSPARENT
	var opening_tween: Tween = create_tween()
	opening_tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUART)
	opening_tween.tween_property(main_panel, ^"size_flags_stretch_ratio", 10, section_in_time)
	opening_tween.set_parallel()
	opening_tween.tween_property(
			main_panel,
			^"modulate",
			Color.WHITE,
			section_in_time / 2.0)
	if dim_background:
		opening_tween.tween_property(dim_light, ^"modulate", Color.WHITE, section_in_time)
	await opening_tween.finished
	if use_search:
		search_panel.visible = true
	if use_close:
		close_button.visible = true
	main_panel.visible = true
	var margin_tween: Tween = create_tween()
	main_margin.visible = true
	margin_tween.tween_property(
			main_margin,
			^"modulate",
			Color.WHITE,
			0.4)
	await margin_tween.finished
	intro_finished.emit()


func play_outro() -> void:
	if use_close:
		close_button.visible = false
	if use_search:
		search_panel.visible = false
	
	var margin_tween: Tween = create_tween()
	main_margin.visible = true
	margin_tween.tween_property(
			main_margin,
			^"modulate",
			Color.TRANSPARENT,
			0.3)
	await margin_tween.finished
	main_margin.visible = false
	
	var close_tween: Tween = create_tween()
	close_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	close_tween.tween_property(main_panel, ^"size_flags_stretch_ratio", 0, section_out_time)
	if dim_background:
		close_tween.parallel()
		close_tween.tween_property(dim_light, ^"modulate", Color.TRANSPARENT, section_out_time)
	await close_tween.finished
	outro_finished.emit()


func set_emit_signals(emit_signals: bool) -> void:
	_allow_signals = emit_signals
