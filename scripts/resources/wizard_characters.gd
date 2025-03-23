class_name TagItStorage
extends Resource


@export var characters: Array[Dictionary] = []


static func get_storage() -> TagItStorage:
	if FileAccess.file_exists("user://data_storage.tres"):
		var res_loader: Resource = load("user://data_storage.tres")
		if res_loader is TagItStorage:
			return res_loader
	return TagItStorage.new()


static func get_empty_character() -> WizardCharacter:
	return WizardCharacter.new()


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
	
	new_character.body_colors = data["colors"].duplicate()
	new_character.apparel = data["apparel"].duplicate()
	new_character.body_traits = data["traits"].duplicate()
	
	return new_character


func set_character(character_data: WizardCharacter, character_index: int = -1) -> void:
	var index: int = characters.size() if character_index == -1 else character_index
	var data: Dictionary = {
		"tag": character_data.character_tag,
		"species": character_data.species,
		"body": character_data.body_type,
		"gender": character_data.gender,
		"gender_lore": character_data.gender_lore,
		"age": character_data.age,
		"age_lore": character_data.age_lore,
		"colors": character_data.body_colors.duplicate(),
		"apparel": character_data.apparel.duplicate(),
		"traits": character_data.body_traits.duplicate()}
	
	if character_index < 0:
		characters.append(data)
	else:
		characters[index] = data


func erase_character(character_tag: String) -> void:
	for idx in range(characters.size()):
		if characters[idx]["tag"] == character_tag:
			characters.remove_at(idx)
			break


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
	var body_colors: Dictionary = {}
	var apparel: Dictionary = {}
	var body_traits: Dictionary = {}
