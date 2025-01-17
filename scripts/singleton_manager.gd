extends Node


signal singletons_ready


var TagIt: DataManager = null
var eSixAPI: ESixManager = null


func _ready() -> void:
	if OS.has_feature("editor"):
		TagIt = DataManager.new()
		add_child(TagIt)
		eSixAPI = ESixManager.new()
		add_child(eSixAPI)


func reload_singletons() -> void:
	if TagIt != null:
		TagIt.queue_free()
		TagIt = null
	if eSixAPI != null:
		eSixAPI.queue_free()
		eSixAPI = null
	
	TagIt = load("res://scripts/tagit_singleton.gd").new()
	add_child.call_deferred(TagIt)
	
	if not TagIt.is_node_ready():
		await TagIt.ready
	
	eSixAPI = load("res://scripts/e_six_requester.gd").new()
	add_child.call_deferred(eSixAPI)
	
	if not eSixAPI.is_node_ready():
		await eSixAPI.ready
	
	singletons_ready.emit()
