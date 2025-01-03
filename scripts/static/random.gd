class_name Random
extends Node


static func generate_random_string(char_count: int = 64) -> String:
	var total: int = char_count
	var item_array: Array[String] = []
	
	var mayus: int = randi_range(roundi(total * 0.25), roundi(total * 0.5))
	total -= mayus
	var numb: int = randi_range(roundi(total * 0.25), roundi(total * 0.5))
	total -= numb
	
	for _loop in range(mayus):
		item_array.append(char(randi_range(65, 90)))
	for _loop in range(numb):
		item_array.append(str(randi_range(0, 9)))
	for _loop in range(total):
		item_array.append(char(randi_range(97, 122)))
	
	item_array.shuffle()
	
	return "".join(item_array)
