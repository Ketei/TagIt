class_name TagItTool
extends Control

@warning_ignore("unused_signal")
signal something_changed
@warning_ignore("unused_signal")
signal disable_save
@warning_ignore("unused_signal")
signal enable_save
@warning_ignore("unused_signal")
signal disable_switch
@warning_ignore("unused_signal")
signal enable_switch


var tool_id: String = "templates"
var tool_description: String = "Create tag list templates."
var requires_save: bool = false


func on_save_pressed() -> void:
	pass
