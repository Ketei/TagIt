class_name TagItStorage
extends Resource


@export var storage_version: int = 1
@export var characters: Array[Dictionary] = []


static func get_storage() -> TagItStorage:
	if FileAccess.file_exists("user://data_storage.tres"):
		var res_loader: Resource = load("user://data_storage.tres")
		if res_loader is TagItStorage:
			return res_loader
	return TagItStorage.new()


static func get_empty_character() -> WizardCharacter:
	return WizardCharacter.new()


static func get_storage_version() -> int:
	return get_storage().storage_version


func character_count() -> int:
	return characters.size()


func get_character(character_index: int) -> WizardCharacter:
	var new_character := WizardCharacter.new()
	var data: Dictionary = characters[character_index]
	
	new_character.character_tag = data["tag"]
	new_character.species = data["species"]
	
	new_character.body_type = data["body"]
	new_character.gender = data["gender"]
	new_character.gender_lore = data["gender_lore"]
	new_character.age = data["age"]
	new_character.age_lore = data["age_lore"]
	
	new_character.properties = data["colors"].duplicate()
	new_character.apparel = data["apparel"].duplicate()
	new_character.traits = data["traits"].duplicate()
	
	return new_character


func set_character(character_data: WizardCharacter, character_index: int = -1) -> int:
	var index: int = characters.size() if character_index == -1 else character_index
	var data: Dictionary = {
		"tag": character_data.character_tag,
		"species": character_data.species,
		"body": character_data.body_type,
		"gender": character_data.gender,
		"gender_lore": character_data.gender_lore,
		"age": character_data.age,
		"age_lore": character_data.age_lore,
		"colors": character_data.properties.duplicate(),
		"apparel": character_data.apparel.duplicate(),
		"traits": character_data.traits.duplicate()}
	
	if character_index < 0:
		characters.append(data)
	else:
		characters[index] = data
	
	return index


func erase_character(character_tag: String) -> void:
	for idx in range(characters.size()):
		if characters[idx]["tag"] == character_tag:
			characters.remove_at(idx)
			break


func has_character(character_tag: String) -> bool:
	for character in characters:
		if character["tag"] == character_tag:
			return true
	return false


func save() -> void:
	ResourceSaver.save(
			self,
			"user://data_storage.tres")


class WizardCharacter extends RefCounted:
	var character_tag: String = ""
	var body_type: int = 0
	var species: String = ""
	var age: int = 4
	var age_lore: int = 0
	var gender: int = 0
	var gender_lore: int = 0
	var properties: Dictionary = {}
	var apparel: Dictionary = {}
	var traits: Dictionary = {}
	
	
	func set_apparel(data: Dictionary) -> void:
		for property in data:
			if typeof(property) != TYPE_STRING or typeof(data[property]) != TYPE_DICTIONARY or not data[property].has_all(["active", "subtypes"]):
				continue
			var subtypes: Dictionary = {}
			for subtype in data[property]["subtypes"]:
				if typeof(data[property]["subtypes"][subtype]) == TYPE_BOOL:
					subtypes[subtype] = data[property]["subtypes"][subtype]
			apparel[property] = {
				"active": data[property]["active"],
				"subtypes": subtypes.duplicate()}
			
	
	
	func set_traits(data: Dictionary) -> void:
		for char_trait in data:
			if typeof(data[char_trait]) == TYPE_BOOL:
				traits[char_trait] = data[char_trait]
	
	
	func set_properties(data: Dictionary) -> void:
		const NUM_TYPES: Array = [TYPE_INT, TYPE_FLOAT]
		var valid_properties: Dictionary = {}
		
		for property in data:
			if typeof(property) != TYPE_STRING or typeof(data[property]) != TYPE_DICTIONARY or not data[property].has_all(["index", "properties", "use"]):
				continue
			if not typeof(data[property]["index"]) in NUM_TYPES or typeof(data[property]["use"]) != TYPE_BOOL or typeof(data[property]["properties"]) != TYPE_ARRAY:
				continue
			
			var new_properties: Array[Dictionary] = []
			
			for given_property in data[property]["properties"]:
				if typeof(given_property) != TYPE_DICTIONARY or not given_property.has_all(["index", "mode", "value"]):
					continue
				if given_property["index"] < 0: #value key is string array
					if typeof(given_property["value"]) != TYPE_ARRAY:
						continue
					var value_property: Array[String] = Array(
							given_property["value"],
							TYPE_STRING,
							&"",
							null)
					var new_property: Dictionary = {"value": value_property}
					new_property.merge(given_property)
					new_properties.append(new_property)
				else:
					if not given_property.has("id") or typeof(given_property["id"]) != TYPE_STRING:
						continue
					match clampi(given_property["mode"], 0, 4) as TreeItem.TreeCellMode:
						TreeItem.CELL_MODE_CHECK:
							var new_property: Dictionary = {
								"value": false if typeof(given_property["value"]) != TYPE_BOOL else given_property["value"]}
							new_property.merge(given_property)
							new_properties.append(new_property)
						TreeItem.CELL_MODE_RANGE:
							if typeof(given_property["value"]) not in NUM_TYPES:
								continue
							var new_property: Dictionary = {
								"value": int(given_property["value"])}
							new_property.merge(given_property)
							new_properties.append(new_property)
			valid_properties[property] = {
				"index": int(data[property]["index"]),
				"use": data[property]["use"],
				"properties": new_properties}
		properties = valid_properties
