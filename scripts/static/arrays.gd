class_name Arrays
extends Node
## A collection of static functions to modify arrays.


## Returns a random item on the array and removes it.
static func pop_random(array_to_pop: Array) -> Variant:
	if array_to_pop.is_empty():
		return null
	var random_index: int = randi_range(0, array_to_pop.size())
	return array_to_pop.pop_at(random_index)


## Switches the data on the [param at] array on the [param from] and [param to]
## indexes.
static func switch_indexes(from: int, to: int, at: Array) -> void:
	var array_size: int = at.size() - 1
	if array_size < from or array_size < to:
		return
	
	var second_memory = at[to]
	at[to] = at[from]
	at[from] = second_memory


## Searches array for target using the Binary Search Algorithm
static func binary_search(array: Variant, target: Variant) -> int:
	match typeof(array):
		TYPE_ARRAY:
			var max_size: int = array.size()
			if 0 < max_size:
				var clamped_idx: int = clampi(array.bsearch(target), 0, max_size - 1)
				return clamped_idx if array[clamped_idx] == target else -1
			else:
				return -1
		TYPE_PACKED_STRING_ARRAY:
			if typeof(target) == TYPE_STRING:
				var max_size: int = array.size()
				if 0 < max_size:
					var clamped_idx: int = clampi(array.bsearch(target), 0, max_size - 1)
					return clamped_idx if array[clamped_idx] == target else -1
				else:
					return -1
			else:
				return -1
		_:
			return -1



#static func _bsearch_array(array: Variant, target: Variant) -> int:
	#var low: int = 0
	#var high: int = array.size() - 1
	#
	#while low <= high:
		#var mid_val: float = low + (high - low) / 2.0
		#var mid: int = roundi(mid_val)
		#
		#if array[mid] == target:
			#return mid
		#elif array[mid] < target: # Right Half
			#low = mid + 1
		#else: # Left Half
			#high = mid - 1
	#
	#return -1


static func move_item(array: Array, from_idx: int, to_idx: int) -> void:
	var insert_item: Variant = array[from_idx]
	
	array.remove_at(from_idx)
	array.insert(to_idx, insert_item)


static func insert_sorted_asc(array: Variant, item: Variant) -> void:
	match typeof(array):
		TYPE_ARRAY:
			if array.is_typed():
				if typeof(item) == array.get_typed_builtin():
					array.insert(array.bsearch(item, false), item)
				else:
					push_error("Can't insert element into typed array.")
			else:
				array.insert(array.bsearch(item, false), item)
		TYPE_PACKED_STRING_ARRAY:
			if typeof(item) == TYPE_STRING:
				array.insert(array.bsearch(item), item)
			else:
				array.insert(array.bsearch(item), var_to_str(item))


static func insert_sorted_desc(array: Array, item: Variant) -> void:
	var low: int = 0
	var high: int = array.size() - 1
	
	while low <= high:
		@warning_ignore("integer_division")
		var mid: int = (low + high) / 2
	
		if array[mid] > item:
			low = mid + 1  # We should insert before this element
		else:
			high = mid - 1  # We should insert after this element
	
	array.insert(low, item)


static func sort_custom_desc(item_a: Variant, item_b: Variant) -> bool:
	return item_b < item_a


static func sort_custom_alphabetically_asc(string_a: String, string_b: String) -> bool:
	return string_a.naturalnocasecmp_to(string_b) < 0


static func sort_custom_alphabetically_desc(string_a: String, string_b: String) -> bool:
	return string_b.naturalnocasecmp_to(string_a) < 0


static func containsn(array: Array, what: String) -> bool:
	var compare: String = what.to_upper()
	for element in array:
		if typeof(element) != TYPE_STRING:
			continue
		if element.to_upper() == compare:
			return true
	return false


static func append_uniques(array_to_append: Variant, items: Variant) -> void:
	var array_to: int = typeof(array_to_append)
	var array_from: int = typeof(items)
	if ( array_to < 28 or 38 < array_to ) or ( array_from < 28 or 38 < array_from ):
		push_error("Provided data isn't Array")
		return
	
	var append_type: int = 0
	
	if array_to == TYPE_ARRAY:
		append_type = array_to_append.get_typed_builtin()
	else:
		match array_to:
			TYPE_PACKED_INT32_ARRAY:
				append_type = TYPE_INT
			TYPE_PACKED_INT64_ARRAY:
				append_type = TYPE_INT
			TYPE_PACKED_FLOAT32_ARRAY:
				append_type = TYPE_FLOAT
			TYPE_PACKED_FLOAT64_ARRAY:
				append_type = TYPE_FLOAT
			TYPE_PACKED_STRING_ARRAY:
				append_type = TYPE_STRING
			TYPE_PACKED_VECTOR2_ARRAY:
				append_type = TYPE_VECTOR2
			TYPE_PACKED_VECTOR3_ARRAY:
				append_type = TYPE_VECTOR3
			TYPE_PACKED_VECTOR4_ARRAY:
				append_type = TYPE_VECTOR4
			TYPE_PACKED_COLOR_ARRAY:
				append_type = TYPE_COLOR
			_:
				append_type = TYPE_NIL
	
	for item in items:
		if not array_to_append.has(item) and (append_type == TYPE_NIL or typeof(item) == append_type):
			array_to_append.append(item)


static func append_uniques_asc(array_to_append: Variant, items: Variant) -> void:
	match typeof(array_to_append):
		TYPE_ARRAY:
			if array_to_append.is_typed():
				var type: int = array_to_append.get_typed_builtin()
				for item in items:
					if typeof(item) == type and not array_to_append.has(item):
						insert_sorted_asc(array_to_append, item)
					else:
						push_error("Array item doesn't match typed array type.")
			else:
				for item in items:
					if not array_to_append.has(item):
						insert_sorted_asc(array_to_append, item)
		TYPE_PACKED_STRING_ARRAY:
			if items.is_typed():
				if items.get_typed_builtin() != TYPE_STRING:
					return
				for item in items:
					if not array_to_append.has(item):
						insert_sorted_asc(array_to_append, item)
			else:
				for item in items:
					if typeof(item) == TYPE_STRING and not array_to_append.has(item):
						insert_sorted_asc(array_to_append, item)


static func substract_array(target_array: Array, substract_items: Array) -> void:
	if target_array.is_empty():
		return
	for item in substract_items:
		var item_idx: int = target_array.find(item)
		if item_idx != -1:
			target_array.remove_at(item_idx)
			if target_array.is_empty():
				break


### [param a_ref_only] will make it so that we only check what items a has
## that b doesn't and skip chekcing what b has that a doesn't.
static func difference(array_a: Array, array_b: Array, a_ref_only: bool = true) -> Array:
	var difference_items: Array = []
	for item in array_a:
		if not array_b.has(item):
			difference_items.append(item)
	if a_ref_only:
		for item in array_b:
			if not array_a.has(item):
				difference_items.append(item)
	return difference_items


static func clean_tag_array(array: Variant) -> void:
	if typeof(array) != TYPE_ARRAY and typeof(array) != TYPE_PACKED_STRING_ARRAY:
		return
	
	for item_idx in range(array.size()):
		if typeof(array[item_idx]) == TYPE_STRING:
			array[item_idx] = array[item_idx].strip_edges().replace("_", " ").to_lower()


static func remove_all(array: Variant, remove_what: Variant) -> void:
	var target_index: int = array.find(remove_what)
	while target_index != -1:
		array.remove_at(target_index)
		target_index = array.find(remove_what)
