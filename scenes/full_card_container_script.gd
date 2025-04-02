class_name CardContainer
extends Container


const CARD_CONTAINER = preload("res://scenes/card_container.tscn")

var margin: float = 20 # Up and down margin

var card: ProjectCard = null
var use_vertical: bool = false


func _ready() -> void:
	add_child(card)
	get_parent().resized.connect(on_resized, ConnectFlags.CONNECT_DEFERRED)


func on_resized():
	if get_child(0) == null:
		return
	
	var child: VBoxContainer = get_child(0)
	var base_size: Vector2 = child.custom_minimum_size
	var target_size: Vector2 = get_parent().size
	
	if use_vertical:
		var max_height: float = get_parent().get_parent().size.y
		var target_width: float = target_size.x - (margin * 2)
		var new_scale: float = target_width / base_size.x
		
		if max_height < (base_size.y * new_scale):
			new_scale = max_height / base_size.y
			target_width = base_size.x * new_scale
		
		var target_pos: float = (target_size.x - target_width) / 2.0
		
		child.scale = Vector2(new_scale, new_scale)
		child.position = Vector2(target_pos, 0)
		size = Vector2(target_width, base_size.y * new_scale)
	else:
		var target_height: float = target_size.y - (margin * 2)
		var target_pos: float = (target_size.y - target_height) / 2.0
		var new_scale: float = target_height * 1.0 / base_size.y
		
		child.scale = Vector2(new_scale, new_scale)
		child.position = Vector2(0, target_pos)
		custom_minimum_size = Vector2(base_size.x * new_scale, 0)


func focus_card() -> void:
	get_child(0).focus_card_button()


func fade_free_card() -> void:
	var fade_tween: Tween = create_tween()
	fade_tween.tween_property(
			self,
			^"modulate",
			Color.TRANSPARENT,
			1.0)
	if not use_vertical:
		fade_tween.set_parallel()
		fade_tween.tween_property(
				self,
				^"custom_minimum_size",
				Vector2(0, size.y),
				1.0)
	await fade_tween.finished
	queue_free()
