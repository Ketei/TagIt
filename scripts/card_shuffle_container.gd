extends Container


signal cards_displayed

# Called when the node enters the scene tree for the first time.

@export_enum("Left", "Right", "Up", "Down") var enter_direction: int = 0
@export_enum("Horizontal", "Vertical") var alignment: int = 0:
	set(new_align):
		alignment = new_align
		grow_horizontal = GrowDirection.GROW_DIRECTION_END if new_align == 0 else GrowDirection.GROW_DIRECTION_BOTH
		grow_vertical = GrowDirection.GROW_DIRECTION_END if new_align == 1 else GrowDirection.GROW_DIRECTION_BOTH
## The time it'll take the children to enter into scene when added in bulk
@export var time_separation: float = 0.2:
	set(separation):
		time_separation = maxf(0.05, separation)
## How long the child will take to reach its destination
@export var position_delay: float = 1.0
## How much each child will be separate from one another.
@export var child_separation: float = 10.0
@export var fade_in_enter: bool = false
@export var animate_limit: int = -1
@export var focus_scale: float = 1.2
@export var initial_margin: float = 10
@export_range(0.05, 1.0, 0.01, "or_greater") var focus_time: float = 0.3
@export_range(0.05, 1.0, 0.01, "or_greater") var drop_time: float = 0.3


@onready var container: Control = $"../.."

#@export var animation_margin: Vector2 = Vector2.ZERO

var queued_children: Array[Control] = []
var _break: bool = false

#var _focused_child: Control


func _ready() -> void:
	alignment = alignment
	for child in get_children():
		if child is Control:
			child.modulate = Color.TRANSPARENT
			queue_child_entry(child)
	enter_children()


func focus_child(child_node: Control) -> void:
	#child_node.set_meta(&"original_position", child_node.position)
	var substract_position: Vector2 = ((child_node.size * focus_scale) - child_node.size) / 2.0
	child_node.scale_card(focus_time, focus_scale)
	child_node.show_buttons(focus_time)
	#travel.tween_property(child_node, ^"scale", focus_scale, maxf(0.05, focus_time))
	var travel: Tween = create_tween()
	travel.tween_property(child_node, ^"position", child_node.position - substract_position, focus_time)


func unfocus_child(child_node: Control) -> void:
	var add_position: Vector2 = (child_node.size - (child_node.size / focus_scale)) / 2.0
	child_node.scale_card(focus_time, 1.0)
	child_node.hide_buttons(focus_time)
	var travel: Tween = create_tween()
	#travel.tween_property(child_node, ^"scale", 1.0, maxf(0.05, focus_time))
	travel.tween_property(child_node, ^"position", child_node.position + add_position, focus_time)


func search_children(search_text: String) -> void:
	for child in get_children():
		if search_text.is_empty() or child.title.containsn(search_text):
			if child.hiding:
				show_child(child)
		else:
			if not child.hiding:
				hide_child(child)
	reorder_children()


func hide_child(card: Control) -> void:
	card.hiding = true
	if alignment == 0:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(card, ^"modulate", Color.TRANSPARENT, 1.0)
		#await tween.finished
		#card.visible = false
	else:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.parallel().tween_property(card, ^"modulate", Color.TRANSPARENT, 1.0)
		#await tween.finished
		#card.visible = false


func show_child(card: Control) -> void:
	card.hiding = false
	if alignment == 0:
		#card.visible = true
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		#tween.tween_property(card, ^"position", Vector2(card.position.x, 0), 1.0)
		tween.tween_property(card, ^"modulate", Color.WHITE, 1.0)
	else:
		#card.visible = true
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(card, ^"position", Vector2(0, card.position.y), 1.0)
		tween.parallel().tween_property(card, ^"modulate", Color.WHITE, 1.0)


func stop_queue() -> void:
	_break = true


func reorder_children() -> void:
	#var starting_position: float = size.y / 2 if alignment == 0 else size.x / 2.0
	var total_size: Vector2 = Vector2.ZERO
	var visible_child: Array[Control] = []
	
	for child in get_children():
		if child is Control:
			if child.hiding:
				continue
			visible_child.append(child)
			if alignment == 0: # Horizontal
				if total_size.y < child.size.y:
					total_size.y = child.size.y
				total_size.x += child.size.x
			else:
				if total_size.x < child.size.x:
					total_size.x = child.size.x
				total_size.y += child.size.y
	
	if alignment == 0: # Horizontal
		var target_position: Vector2 = Vector2.ZERO
		for child in visible_child:
			var tween: Tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(child, ^"position", target_position, position_delay)
			target_position.x += child.size.x + child_separation
	else:
		var target_position: Vector2 = Vector2.ZERO
		for child: Control in get_children():
			var tween: Tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CIRC)
			tween.tween_property(child, ^"position", target_position, position_delay)
			#child.position.x = 0
			#child.position.y = total_size.y
			target_position.y += child.size.y + child_separation
	
	custom_minimum_size = total_size if Vector2(350, 500) <= total_size else Vector2(350, 500)


func change_custom_minimum_size(x: float, y: float) -> void:
	if 0 < x:
		custom_minimum_size.x = x
	if 0 < y:
		custom_minimum_size.y = y
	
	for child in get_children():
		if child is Control:
			if alignment == 0: # Horizontal
				child.position = Vector2(
					child.position.x,
					(custom_minimum_size.y / 2.0) - (child.size.y / 2.0))
				#child.position.y = 
			else:
				child.position.x = (custom_minimum_size.x / 2.0) - (child.size.x / 2.0)


func queue_child_entry(child: Control) -> void:
	queued_children.append(child)


func enter_children() -> void:
	if _break:
		_break = false
	
	if queued_children.is_empty():
		cards_displayed.emit()
		return
	
	var _queued_children: Array[Control] = queued_children.duplicate()
	queued_children.clear()
	
	var new_custom_minimum_size: Vector2 = custom_minimum_size
	var last_target_vector: Vector2
	
	if alignment == 0:
		if new_custom_minimum_size.x == 0:
			new_custom_minimum_size.x = initial_margin
		else:
			new_custom_minimum_size.x -= initial_margin # Removing ending from target
			
		last_target_vector = Vector2(
			new_custom_minimum_size.x,
			0)
		#new_custom_minimum_size.x += initial_margin
		
	else:
		last_target_vector = Vector2(
			0,
			custom_minimum_size.y)
	
	
	for child in _queued_children:
		child.modulate = Color.TRANSPARENT
		if not child.is_inside_tree():
			add_child(child)
		
		if alignment == 0: # Horiz
			new_custom_minimum_size.x += child.size.x
			if child.get_index() != 0:
				new_custom_minimum_size.x += child_separation
			
			if new_custom_minimum_size.y < child.size.y:
				new_custom_minimum_size.y = child.size.y
		else:
			new_custom_minimum_size.y += child.size.y
			if child.get_index() != 0:
				new_custom_minimum_size.y += child_separation
			if new_custom_minimum_size.x < child.size.x:
				new_custom_minimum_size.x = child.size.x
	
	new_custom_minimum_size.x += initial_margin
	
	change_custom_minimum_size(new_custom_minimum_size.x, new_custom_minimum_size.y)
	
	var current_card: int = 0
	
	for child in _queued_children:
		current_card += 1
		var target_position: Vector2 = last_target_vector
		if alignment == 0: #Horizontal
			#if child.get_index() != 0:
				#target_position.x += child_separation 
			last_target_vector.x += child.size.x + child_separation
		else:
			if child.get_index() != 0:
				last_target_vector.y += child_separation
			last_target_vector.y += child.size.y + child_separation
		
		match enter_direction: 
			0: # Left
				child.position.x = maxf(-child.size.x, target_position.x - get_viewport_rect().size.x)
				child.position.y = target_position.y
			1: # Right
				child.position.x = get_viewport_rect().size.x + target_position.x
				child.position.y = target_position.y
			2: # Up
				child.position.y = -child.size.y
				child.position.x = target_position.x
			3: #down
				child.position.y = custom_minimum_size.y
				child.position.x = target_position.x
		
		if current_card < animate_limit:
			var tweener: Tween = create_tween()
			tweener.set_ease(Tween.EASE_OUT)
			tweener.set_trans(Tween.TRANS_CIRC)
			tweener.tween_property(child, ^"position", target_position, position_delay)
			if fade_in_enter:
				tweener.parallel().tween_property(child, ^"modulate", Color.WHITE, position_delay * 1.5)
			else:
				child.modulate = Color.WHITE
			await get_tree().create_timer(time_separation).timeout
		else:
			child.position = target_position
			child.modulate = Color.WHITE
		if _break:
			break
	cards_displayed.emit()


func drop_card(card: Control) -> void:
	card.hiding = true
	if alignment == 0:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(card, ^"modulate", Color.TRANSPARENT, drop_time)
		tween.parallel().tween_property(card, ^"position", Vector2(card.position.x, custom_minimum_size.y), drop_time)
		await tween.finished
		card.queue_free()
	else:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CIRC)
		tween.tween_property(card, ^"modulate", Color.TRANSPARENT, drop_time)
		tween.parallel().tween_property(card, ^"position", custom_minimum_size.x, drop_time)
		await tween.finished
		card.queue_free()
