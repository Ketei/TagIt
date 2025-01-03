extends PanelContainer

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
]

var tool_scene: Control = null

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


func on_template_deleted(template_idx: int) -> void:
	if tool_scene != null and tool_scene.TOOL_ID == "templates":
		tool_scene.on_template_deleted(template_idx)
		


func on_tool_selected(idx: int) -> void:
	if tool_scene != null:
		tool_scene.queue_free()
	var new_id: int = option_button.get_item_id(idx)
	tool_scene = TOOLS[new_id]["scene"].instantiate()
	tool_margin.add_child(tool_scene)
	tool_desc_lbl.text = tool_scene.tool_description
	save_button.disabled = not tool_scene.requires_save
	if save_button.disabled:
		save_button.tooltip_text = "Tool doesn't require saving"
	else:
		save_button.tooltip_text = "Save tool configuration"


func on_save_pressed() -> void:
	if tool_scene == null:
		return
	
	tool_scene.on_save_pressed()
	saved_notification.visible = true
	save_button.disabled = true
	
	var tween_slide := get_tree().create_tween()
	
	tween_slide.tween_property(saved_notification, "modulate", Color.TRANSPARENT, 1.0)
	tween_slide.set_parallel()
	tween_slide.tween_property(saved_notification, "position", Vector2(-54, 76), 1.0)
	
	await tween_slide.finished
	
	saved_notification.visible = false
	saved_notification.modulate = Color.WHITE
	saved_notification.position = Vector2(-54, 38)
	save_button.disabled = false
