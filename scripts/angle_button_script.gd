extends Button

const ICON_OFF = preload("res://icons/check_cross_icon.svg")
const ICON_ON = preload("res://icons/icon_checked.svg")


@export var angle_tags: Array[String] = []
@export var is_angle_selected: bool = false:
	set(pressed):
		is_angle_selected = pressed
		if is_node_ready():
			checked_texture.texture = ICON_ON if pressed else ICON_OFF
@export var angle_texture: Texture = null:
	set(new_texture):
		angle_texture = new_texture
		if is_node_ready():
			angle_text_rect.texture = new_texture

@onready var angle_text_rect: TextureRect = $PanelContainer/MarginContainer/TextureContainer/AngleTexture
@onready var checked_texture: TextureRect = $PanelContainer/MarginContainer/TextureContainer/CheckedTexture


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	custom_minimum_size = Vector2(110, 130)
	checked_texture.texture = ICON_ON if is_angle_selected else ICON_OFF
	angle_text_rect.texture = angle_texture
	pressed.connect(on_button_pressed)
	

func on_button_pressed() -> void:
	is_angle_selected = not is_angle_selected
