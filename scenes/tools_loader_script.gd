extends PanelContainer


signal tags_requested

const TOOLS: Array[Dictionary] = [
	{
		"scene": preload("res://scenes/tools/aliaser.tscn"),
		"name": "Tag Aliaser"
	},
	{
		"scene": preload("res://scenes/tools/templates.tscn"),
		"name": "List Templates"
	},
	{
		"scene": preload("res://scenes/tools/prefixes.tscn"),
		"name": "Prefixes"
	},
	{
		"scene": preload("res://scenes/tools/tag_validator.tscn"),
		"name": "Tag Validator"
	},
	{
		"scene": preload("res://scenes/tools/tag_fetcher.tscn"),
		"name": "Tag Fetcher"
	},
	{
		"scene": preload("res://scenes/tools/wizard_character.tscn"),
		"name": "Wizard Characters"
	},
]

const MessageConfirmationDialog = preload("res://scenes/dialogs/message_confirmation_dialog.gd")

var tool_scene: TagItTool = null
var warn_unsaved: bool = false
var current_tool_idx: int = -1

@onready var option_button: OptionButton = $ToolsMargin/ToolsContainer/HeaderContainer/OptionButton
@onready var save_button: Button = $ToolsMargin/ToolsContainer/HeaderContainer/SaveButton
@onready var tool_desc_lbl: Label = $ToolsMargin/ToolsContainer/HeaderContainer/ToolDescLbl
@onready var tool_margin: MarginContainer = $ToolsMargin/ToolsContainer/ToolPanel/ToolMargin
@onready var saved_notification: PanelContainer = $ToolsMargin/ToolsContainer/HeaderContainer/SaveButton/SavedNotification


func _ready() -> void:
	for tool_idx in range(TOOLS.size()):
		option_button.add_item(TOOLS[tool_idx]["name"], tool_idx)
	
	if 0 < option_button.item_count:
		option_button.select(0)
		on_tool_selected(0)
	
	saved_notification.visible = false
	
	option_button.item_selected.connect(on_tool_selected)
	save_button.pressed.connect(on_save_pressed)


func on_template_deleted(template_uuid: String) -> void:
	if tool_scene != null and tool_scene.TOOL_ID == "templates":
		tool_scene.on_template_deleted(template_uuid)


func on_tool_selected(idx: int) -> void:
	if warn_unsaved:
		var unsaved_window := MessageConfirmationDialog.new()
		unsaved_window.message = "You have unsaved changes.\nSwitching tools will discard them."
		unsaved_window.title = "Unsaved Changes"
		unsaved_window.ok_button_text = "Switch"
		unsaved_window.cancel_button_text = "Cancel"
		add_child(unsaved_window)
		unsaved_window.show()
		
		var continue_unsaved: bool = await unsaved_window.dialog_finished
		
		unsaved_window.queue_free()
		if not continue_unsaved:
			option_button.select(current_tool_idx)
			return
	
	if tool_scene != null:
		if tool_scene.tool_id == "tag_fetch":
			tool_scene.tag_list_requested.disconnect(fetch_tags_requested)
		tool_scene.something_changed.disconnect(_on_tool_something_changed)
		tool_scene.disable_save.disconnect(_on_tool_set_save.bind(false))
		tool_scene.enable_save.disconnect(_on_tool_set_save.bind(true))
		tool_scene.disable_switch.disconnect(_on_tool_set_switch.bind(false))
		tool_scene.enable_switch.disconnect(_on_tool_set_switch.bind(true))
		tool_scene.queue_free()
	option_button.disabled = false
	
	var new_id: int = option_button.get_item_id(idx)
	
	tool_scene = TOOLS[new_id]["scene"].instantiate()
	tool_margin.add_child(tool_scene)
	tool_desc_lbl.text = tool_scene.tool_description
	save_button.disabled = not tool_scene.requires_save
	tool_scene.something_changed.connect(_on_tool_something_changed)
	tool_scene.disable_save.connect(_on_tool_set_save.bind(false))
	tool_scene.enable_save.connect(_on_tool_set_save.bind(true))
	tool_scene.disable_switch.connect(_on_tool_set_switch.bind(false))
	tool_scene.enable_switch.connect(_on_tool_set_switch.bind(true))
	if tool_scene.tool_id == "tag_fetch":
		tool_scene.tag_list_requested.connect(fetch_tags_requested)
	
	if save_button.disabled:
		save_button.tooltip_text = "Tool doesn't require saving"
	else:
		save_button.tooltip_text = "Save tool configuration"
	
	current_tool_idx = idx
	warn_unsaved = false


func fetch_tags_requested() -> void:
	tags_requested.emit()


func submit_tags(tags: Array[String]) -> void:
	if tool_scene != null and tool_scene.tool_id == "tag_fetch":
		tool_scene.load_tags(tags)


func _on_tool_something_changed() -> void:
	if not warn_unsaved:
		warn_unsaved = true


func _on_tool_set_save(set_enabled: bool) -> void:
	save_button.disabled = not set_enabled


func _on_tool_set_switch(set_enabled: bool) -> void:
	option_button.disabled = not set_enabled


func on_save_pressed() -> void:
	if tool_scene == null:
		return
	
	if warn_unsaved:
		warn_unsaved = false
	
	tool_scene.on_save_pressed()
	saved_notification.visible = true
	save_button.disabled = true
	
	var tween_slide := get_tree().create_tween()
	
	tween_slide.tween_property(saved_notification, "modulate", Color.TRANSPARENT, 1.0)
	tween_slide.set_parallel()
	tween_slide.tween_property(saved_notification, "position", Vector2(1, 80), 1.0)
	
	await tween_slide.finished
	
	saved_notification.visible = false
	saved_notification.modulate = Color.WHITE
	saved_notification.position = Vector2(1, 38)
	save_button.disabled = false
