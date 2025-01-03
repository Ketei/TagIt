extends VBoxContainer


signal card_selected
signal card_confirmed
signal card_deleted
signal card_saved(title: String)
signal card_cancelled


var title: String = "" :
	set(new_title):
		title = new_title
		if is_node_ready():
			title_label.text = new_title
var description: String = "" :
	set(new_desc):
		description = new_desc
		if is_node_ready():
			desc_label.text = new_desc
var image: Texture2D = null:
	set(new_texture):
		image = new_texture
		if is_node_ready():
			image_texrec.texture = image
var hiding: bool = false
var show_description: bool = true:
	set(show_desc):
		show_description = show_desc
		if is_node_ready():
			desc_label.visible = show_desc
var editable: bool = false
var use_save: bool = false
#var _animating_buttons: bool = false
#var _animating_card: bool = false


@onready var edit_title_line_edit: LineEdit = $MenuCard/MainMargin/MainContainer/TitlePanel/TitleMargin/EditTitleLineEdit
@onready var desc_edit_text_edit: TextEdit = $MenuCard/MainMargin/MainContainer/DescEditTextEdit
@onready var title_label: Label = $MenuCard/MainMargin/MainContainer/TitlePanel/TitleMargin/TitleLabel
@onready var image_texrec: TextureRect = $MenuCard/MainMargin/MainContainer/ImagePanel/ImageMargin/Image
@onready var desc_label: Label = $MenuCard/MainMargin/MainContainer/DescLabel
@onready var buttons_containtainer: PanelContainer = $MenuCard/PanelContainer
@onready var menu_card: PanelContainer = $MenuCard
@onready var glow_container: PanelContainer = $MenuCard/GlowContainer
@onready var save_button: Button = $SaveButton
@onready var card_select_button: Button = $MenuCard/CardSelectButton
@onready var cancel_button: Button = $CancelButton



func _ready() -> void:
	edit_title_line_edit.visible = editable
	title_label.visible = not editable
	
	if show_description:
		desc_edit_text_edit.visible = editable
		desc_label.visible = not editable
	else:
		desc_label.visible = false
	
	save_button.visible = use_save
	cancel_button.visible = use_save
	card_select_button.visible = not use_save
	
	title_label.text = title
	desc_label.text = description
	image_texrec.texture = image

	#desc_label.visible = show_description
	card_select_button.pressed.connect(card_selected.emit)
	$MenuCard/PanelContainer/MarginContainer/ButtonsContaintainer/SelectButton.pressed.connect(card_confirmed.emit)
	$MenuCard/PanelContainer/MarginContainer/ButtonsContaintainer/DeleteButton.pressed.connect(card_deleted.emit)
	save_button.pressed.connect(on_card_saved)
	cancel_button.pressed.connect(card_cancelled.emit)


func on_card_saved() -> void:
	card_saved.emit(edit_title_line_edit.text.strip_edges())


func show_buttons(time: float) -> void:
	#if _animating_buttons:
		#return
	#_animating_buttons = true
	buttons_containtainer.visible = true
	glow_container.visible = true
	glow_container.modulate = Color.TRANSPARENT
	buttons_containtainer.modulate = Color.TRANSPARENT
	var display: Tween = create_tween()
	display.tween_property(buttons_containtainer, ^"modulate", Color.WHITE, maxf(0.05, time))
	display.parallel().tween_property(glow_container, ^"modulate", Color.WHITE, maxf(0.05, time))
	#_animating_buttons = false


func hide_buttons(time: float) -> void:
	#if _animating_buttons:
		#return
	#_animating_buttons = true
	var display: Tween = create_tween()
	display.tween_property(buttons_containtainer, ^"modulate", Color.TRANSPARENT, maxf(0.05, time))
	display.parallel().tween_property(glow_container, ^"modulate", Color.TRANSPARENT, maxf(0.05, time))
	await display.finished
	buttons_containtainer.visible = false
	glow_container.visible = false
	#_animating_buttons = false


func scale_card(time: float, new_scale: float) -> void:
	#if _animating_card:
		#return
	#_animating_card = true
	var display: Tween = create_tween()
	display.tween_property(menu_card, ^"scale", Vector2.ONE * new_scale, maxf(0.01, time))
	#_animating_card = false
