extends PanelContainer


signal blacklist_submitted
signal blacklist_cancelled


var suggestion_blacklist: PackedStringArray = []
var group_blacklist: PackedInt64Array = []

@onready var tags_tree: Tree = $MainCenter/MainPanel/MainMargin/VBoxContainer/HBoxContainer/MainContainer/TagsTree
@onready var add_tag_ln_edt: LineEdit = $MainCenter/MainPanel/MainMargin/VBoxContainer/HBoxContainer/MainContainer/AddTagLnEdt
@onready var cancel_button: Button = $MainCenter/MainPanel/MainMargin/VBoxContainer/ButtonContainer/CancelButton
@onready var save_button: Button = $MainCenter/MainPanel/MainMargin/VBoxContainer/ButtonContainer/SaveButton
@onready var groups_tree: Tree = $MainCenter/MainPanel/MainMargin/VBoxContainer/HBoxContainer/GroupBlacklist/GroupsTree


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tags_tree.create_item()
	groups_tree.create_item()
	
	for suggestion in suggestion_blacklist:
		add_tag(suggestion)
	
	var groups: Dictionary = SingletonManager.TagIt.get_tag_groups()
	
	for group in group_blacklist:
		add_group(group, groups[group]["name"])
	
	tags_tree.focus_exited.connect(on_tag_tree_focus_lost)
	save_button.pressed.connect(on_ok_pressed)
	cancel_button.pressed.connect(on_cancel_pressed)
	add_tag_ln_edt.text_submitted.connect(_on_add_tag_text_submitted)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_text_delete"):
		if tags_tree.has_focus():
			var current: TreeItem = tags_tree.get_next_selected(null)
			while current != null:
				var next: TreeItem = tags_tree.get_next_selected(current)
				current.free()
				current = next
			get_viewport().set_input_as_handled()
		elif groups_tree.has_focus():
			var current: TreeItem = groups_tree.get_next_selected(null)
			while current != null:
				var next: TreeItem = groups_tree.get_next_selected(current)
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


func add_group(group_id: int, group_name: String) -> void:
	var new_id: TreeItem = groups_tree.get_root().create_child()
	new_id.set_text(0, group_name)
	new_id.set_metadata(0, group_id)


func on_ok_pressed() -> void:
	suggestion_blacklist.clear()
	group_blacklist.clear()
	
	for tag in tags_tree.get_root().get_children():
		suggestion_blacklist.append(tag.get_text(0))
	
	for grp in groups_tree.get_root().get_children():
		group_blacklist.append(grp.get_metadata(0))
	
	blacklist_submitted.emit()


func on_cancel_pressed() -> void:
	blacklist_cancelled.emit()
