class_name CardContainer
extends Container


const CARD_CONTAINER = preload("res://scenes/card_container.tscn")

var margin: float = 20 # Up and down margin

var card: ProjectCard = null


func _ready() -> void:
	add_child(card)
	get_parent().resized.connect(on_resized, ConnectFlags.CONNECT_DEFERRED)


func on_resized():
	if get_child(0) == null:
		return
	
	var child: VBoxContainer = get_child(0)
	var base_size: Vector2 = child.custom_minimum_size
	var target_size: Vector2 = get_parent().size
	
	var target_height: float = target_size.y - (margin * 2)
	var target_pos: float = (target_size.y - target_height) / 2.0
	var new_width: float = floorf(target_height * base_size.x / base_size.y)
	
	child.size = Vector2(new_width, target_height)
	child.position = Vector2(0, target_pos)
	custom_minimum_size = Vector2(new_width, 0)


func focus_card() -> void:
	get_child(0).focus_card_button()
