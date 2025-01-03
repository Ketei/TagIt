class_name TagRelationsRes
extends Resource


const RES_PATH: String = "res://database_relations.tres" #"user://database_relations.tres"
@export var relations: Dictionary = {} # int : {"parents": PackedIntArray, "suggestions": PackedIntArray}


static func get_relations_resource() -> TagRelationsRes:
	if ResourceLoader.exists(RES_PATH):
		var res_preload: Resource = load(RES_PATH)
		if res_preload is TagRelationsRes:
			return res_preload
	return TagRelationsRes.new()


func create_id(id: int) -> void:
	relations[id] = {
		"parents": PackedInt32Array(),
		"suggestions": PackedInt32Array(),
		"group_suggestions": PackedInt32Array()}


func remove_id(id: int) -> void:
	relations.erase(id)


func has_id(id: int) -> void:
	relations.has(id)


func has_parents(id: int) -> bool:
	return relations.has(id) and not relations[id]["parents"].is_empty()


func get_parent_ids(tag_id: int) -> Array[int]:
	var parents: Array[int] = []
	for parent in relations[tag_id]["parents"]:
		parents.append(parent)
	return parents


func get_suggestion_ids(tag_id: int) -> Array[int]:
	var suggestions: Array[int] = []
	for suggestion in relations[tag_id]["suggestions"]:
		suggestions.append(suggestion)
	return suggestions


func get_group_suggestions(tag_id: int) -> Array[int]:
	var group_suggestions: Array[int] = []
	group_suggestions.assign(relations[tag_id]["group_suggestions"])
	return group_suggestions


func add_parents(tag_id: int, parents: Array[int]) -> void:
	for parent in parents:
		relations[tag_id]["parents"].append(parent)


func add_suggestions(tag_id: int, suggestions: Array[int]) -> void:
	for suggestion in suggestions:
		relations[tag_id]["suggestions"].append(suggestion)


func add_group_suggestions(tag_id: int, suggestions: Array[int]) -> void:
	for suggestion in suggestions:
		relations[tag_id]["group_suggestions"].append(suggestion)


func clear_parents(tag_id: int) -> void:
	relations[tag_id]["parents"].clear()


func clear_suggestions(tag_id: int) -> void:
	relations[tag_id]["suggestions"].clear()


func clear_group_suggestions(tag_id: int) -> void:
	relations[tag_id]["group_suggestions"].clear()


func has_parent(tag_id: int, parent: int) -> bool:
	return relations[tag_id]["parents"].find(parent) != -1


func has_suggestion(tag_id: int, suggestion: int) -> bool:
	return relations[tag_id]["suggestions"].find(suggestion) != -1


func has_group_suggestion(tag_id: int, suggestion: int) -> bool:
	return relations[tag_id]["group_suggestions"].find(suggestion) != -1


func remove_parent(tag_id: int, parent: int) -> void:
	var idx: int = relations[tag_id]["parents"].find(parent)
	relations[tag_id]["parents"].remove_at(idx)


func remove_suggestion(tag_id: int, suggestion: int) -> void:
	var idx: int = relations[tag_id]["suggestions"].find(suggestion)
	relations[tag_id]["suggestions"].remove_at(idx)


func remove_group_suggestion(tag_id: int, suggestion: int) -> void:
	var idx: int = relations[tag_id]["group_suggestions"].find(suggestion)
	relations[tag_id]["group_suggestions"].remove_at(idx)


func save() -> void:
	if ResourceSaver.save(self, RES_PATH) != OK:
		printerr("There was an error while saving relations.")
