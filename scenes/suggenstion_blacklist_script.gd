extends PanelContainer


signal blacklist_submitted(new_blacklist: PackedStringArray)
signal blacklist_cancelled


var suggestion_blacklist: PackedStringArray = []
@onready var tags_tree: Tree = $MainCenter/MainPanel/MainMargin/MainContainer/TagsTree
@onready var cancel_button: Button = $MainCenter/MainPanel/MainMargin/MainContainer/ButtonContainer/CancelButton
@onready var save_button: Button = $MainCenter/MainPanel/MainMargin/MainContainer/ButtonContainer/SaveButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tags_tree.create_item()
	
	for suggestion in suggestion_blacklist:
		add_tag(suggestion)
	
	tags_tree.focus_exited.connect(on_tag_tree_focus_lost)
	save_button.pressed.connect(on_ok_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)


func _input(_event: InputEvent) -> void:
	if tags_tree.has_focus() and Input.is_action_just_pressed(&"ui_text_delete"):
		var current: TreeItem = tags_tree.get_next_selected(null)
		while current != null:
			var next: TreeItem = tags_tree.get_next_selected(current)
			current.free()
			current = next
		get_viewport().set_input_as_handled()


func on_tag_tree_focus_lost() -> void:
	tags_tree.deselect_all()


func add_tag(tag: String) -> void:
	var new_tag: TreeItem = tags_tree.get_root().create_child()
	new_tag.set_text(0, tag)


func on_ok_pressed() -> void:
	var new_black := PackedStringArray()
	
	for tag in tags_tree.get_root().get_children():
		new_black.append(tag.get_text(0))
	
	blacklist_submitted.emit(new_black)


func on_cancel_pressed() -> void:
	blacklist_cancelled.emit()
