class_name Math
extends Node


static func is_between(what: float, between_a: float, between_b: float) -> bool:
	var min_value = minf(between_a, between_b)
	var max_value = maxf(between_b, between_b)
	
	return min_value <= what and what <= max_value


static func is_betweeni(what: int, between_a: int, between_b: int) -> bool:
	var min_value = mini(between_a, between_b)
	var max_value = maxi(between_b, between_b)
	
	return min_value <= what and what <= max_value
