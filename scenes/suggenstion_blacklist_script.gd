extends PanelContainer


signal blacklist_submitted
signal blacklist_cancelled


var suggestion_blacklist: PackedStringArray = []
@onready var tags_tree: Tree = $MainCenter/MainPanel/MainMargin/MainContainer/TagsTree
@onready var cancel_button: Button = $MainCenter/MainPanel/MainMargin/MainContainer/ButtonContainer/CancelButton
@onready var save_button: Button = $MainCenter/MainPanel/MainMargin/MainContainer/ButtonContainer/SaveButton
@onready var add_tag_ln_edt: LineEdit = $MainCenter/MainPanel/MainMargin/MainContainer/AddTagLnEdt


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tags_tree.create_item()
	
	for suggestion in suggestion_blacklist:
		add_tag(suggestion)
	
	tags_tree.focus_exited.connect(on_tag_tree_focus_lost)
	save_button.pressed.connect(on_ok_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)
	add_tag_ln_edt.text_submitted.connect(_on_add_tag_text_submitted)


func _input(_event: InputEvent) -> void:
	if tags_tree.has_focus() and Input.is_action_just_pressed(&"ui_text_delete"):
		var current: TreeItem = tags_tree.get_next_selected(null)
		while current != null:
			var next: TreeItem = tags_tree.get_next_selected(current)
			current.free()
			current = next
		get_viewport().set_input_as_handled()


func _on_add_tag_text_submitted(new_tag: String) -> void:
	var clean_text: String = new_tag.strip_edges().to_lower()
	add_tag_ln_edt.clear()
	if not has_tag(clean_text):
		add_tag(clean_text)


func has_tag(tag: String) -> bool:
	return suggestion_blacklist.has(tag)


func on_tag_tree_focus_lost() -> void:
	tags_tree.deselect_all()


func add_tag(tag: String) -> void:
	var new_tag: TreeItem = tags_tree.get_root().create_child()
	new_tag.set_text(0, tag)


func on_ok_pressed() -> void:
	var new_black := PackedStringArray()
	
	for tag in tags_tree.get_root().get_children():
		new_black.append(tag.get_text(0))
	
	suggestion_blacklist.clear()
	suggestion_blacklist.append_array(new_black)
	
	blacklist_submitted.emit()


func on_cancel_pressed() -> void:
	blacklist_cancelled.emit()
