class_name Strings
extends Node


static func nocasecmp_equal(string_a: String, string_b: String) -> bool:
	return string_a.to_upper() == string_b.to_upper()


# Random string based on time. Less probability of collission
static func random_string64() -> String:
	var random_array: PackedByteArray = var_to_bytes(Time.get_unix_time_from_system())
	for _a in range(36): # Each 3 adds 4 more characters
		random_array.append(randi() & 0xFF)
	
	return Marshalls.raw_to_base64(random_array).replace("+", "-").replace("/", "_")


static func random_string(num_chars: int) -> String:
	var byte_array := PackedByteArray()
	
	for _a in range(num_chars):
		byte_array.append(randi() & 0xFF)
	
	return (Marshalls.raw_to_base64(byte_array)
		.replace("+", "-")
		.replace("/", "_")
		.replace("=", "")
		.substr(0, num_chars))


static func title_case(text: String) -> String:
	var titled_string: String = ""
	for idx in range(text.length()):
		if idx == 0 or text[idx - 1] == " ":
			titled_string += text[idx].capitalize()
		else:
			titled_string += text[idx].to_lower()
	return titled_string


static func split_and_strip(what: String, delimeter: String, allow_empty: bool = false) -> Array[String]:
	var pieces: Array[String] = []
	for piece in what.split(delimeter, allow_empty):
		pieces.append(piece.strip_edges())
	return pieces


static func begins_with_nocasecmp(what: String, begins_with: String) -> bool:
	return what.to_upper().begins_with(begins_with.to_upper())


static func is_invalid_prefix_character(unicode: int) -> bool:
	# Mayus
	return Math.is_between(unicode, 65, 90) or\
			# Minus
			Math.is_between(unicode, 97, 122) or\
			# Numbers
			Math.is_between(unicode, 48, 57) or\
			# "_"
			unicode == 95


static func split_tags(text: String, whitespace: String, separator: String) -> PackedStringArray:
	var packed := PackedStringArray()
	for tag in split_and_strip(text, separator):
		packed.append(tag.replace(whitespace, " "))
	return packed


static func split_overlapping(text: String, chunk_size: int) -> Array[String]:
	var result: Array[String] = []
	var start: int = 0
	
	while start <= text.length() - chunk_size:
		result.append(text.substr(start, chunk_size))
		start += 1
	
	return result


static func levenshtein_distance(string_1: String, string_2: String) -> float:
	# Written by ChatGPT
	var len_1: int = string_1.length()
	var len_2: int = string_2.length()
	
	# Empty vs something = completely different
	if (len_1 == 0 and len_2 != 0) or (len_2 == 0 and len_1 != 0):
		return 0.0

	# Initialize a 2D array to store the distances
	var dp: Array[Array] = []
	for i in range(len_1 + 1):
		dp.append([])
		for j in range(len_2 + 1):
			dp[i].append(0)
	
	# Initialize the first row and column of the array
	for i in range(len_1 + 1):
		dp[i][0] = i
	for j in range(len_2 + 1):
		dp[0][j] = j
	
	# Calculate Levenshtein distance
	for i in range(1, len_1 + 1):
		for j in range(1, len_2 + 1):
			if string_1[i - 1] == string_2[j - 1]:
				dp[i][j] = dp[i - 1][j - 1]
			else:
				dp[i][j] = min(dp[i - 1][j] + 1, dp[i][j - 1] + 1, dp[i - 1][j - 1] + 1)
	
	# Calculate similarity (1 - normalized distance)
	var distance: int = dp[len_1][len_2]
	var max_len:int = maxi(len_1, len_2)
	var similarity: float = 1.0 - float(distance) / float(max_len)
	return similarity
