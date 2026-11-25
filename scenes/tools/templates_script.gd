extends TagItTool


const MessageConfirmationDialog = preload("res://scenes/dialogs/message_confirmation_dialog.gd")

var template_resource: TemplateResource = null
var loaded_template: TagItTemplate = null
var current_template: TreeItem = null:
	set(new_current):
		current_template = new_current
		var valid_id: bool = current_template != null
		add_tag_ln_edt.editable = valid_id
		template_title.editable = valid_id
		description_txt_edt.editable = valid_id
		select_thumb_button.disabled = not valid_id
		select_thumb_button.disabled = not valid_id
		set_groups_editable(valid_id)

var all_templates: Dictionary[String, Dictionary] = {
	#"uuid": {"template": null, "edited": false}
}

var template_edited: bool = false:
	set(is_edited):
		if loaded_template != null:
			all_templates[loaded_template._uuid]["edited"] = is_edited
	get():
		if loaded_template != null:
			return all_templates[loaded_template._uuid]["edited"]
		return false

@onready var tags_tree: Tree = $SetupContainer/TagsContainer/TagsTree
@onready var group_tree: Tree = $SetupContainer/GroupsContainer/GroupTree
@onready var template_title: LineEdit = $SetupContainer/InfoContaienr/TitleContainer/TemplateTitle
@onready var description_txt_edt: TextEdit = $SetupContainer/InfoContaienr/TitleContainer/DescriptionTxtEdt
@onready var thumbnail_container: TextureRect = $SetupContainer/InfoContaienr/ImageContainer/PanelContainer/ThumbnailContainer

@onready var template_tree: Tree = $TemplatesContainer/TemplateTree
@onready var search_template_ln_edt: LineEdit = $TemplatesContainer/HeaderContainer/SearchTemplateLnEdt
@onready var new_template_btn: Button = $TemplatesContainer/HeaderContainer/NewTemplateBtn
@onready var add_tag_ln_edt: LineEdit = $SetupContainer/TagsContainer/AddTagLnEdt
@onready var select_thumb_button: Button = $SetupContainer/InfoContaienr/ImageContainer/ButtonContainer/SelectThumbButton
@onready var clear_thumbnail: Button = $SetupContainer/InfoContaienr/ImageContainer/ButtonContainer/ClearThumbnail
@onready var search_group_ln_edt: LineEdit = $SetupContainer/GroupsContainer/SearchGroupLnEdt


func _init() -> void:
	tool_id = "templates"
	tool_description = "Create tag list templates."
	requires_save = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	template_tree.create_item()
	group_tree.create_item()
	tags_tree.create_item()
	
	template_resource = TemplateResource.get_templates()
	
	for template_id in template_resource.get_template_uuids():
		var title: String = template_resource.template_map[template_id]["title"]
		var new_template: TreeItem = template_tree.get_root().create_child()
		new_template.set_text(0, title)
		new_template.set_metadata(0, template_id)
	
	var groups: Dictionary = SingletonManager.TagIt.get_tag_groups()
	
	var group_arrays: Array[Array] = []
	
	for group_id in groups:
		group_arrays.append([group_id, groups[group_id]["name"]])
	
	group_arrays.sort_custom(_sort_groups_array)
	
	for array in group_arrays:
		var new_group: TreeItem = group_tree.get_root().create_child()
		new_group.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_group.set_text(0, array[1])
		new_group.set_metadata(0, array[0])
		new_group.set_editable(0, false)
	
	template_title.text_changed.connect(_on_title_changed)
	description_txt_edt.text_changed.connect(_on_field_edited)
	group_tree.item_edited.connect(_on_group_edited)
	select_thumb_button.pressed.connect(_on_select_thumbnail_pressed)
	add_tag_ln_edt.text_submitted.connect(_on_tag_text_submitted)
	search_group_ln_edt.text_changed.connect(_on_search_group_text_changed)
	search_template_ln_edt.text_changed.connect(_on_search_template_text_changed)
	new_template_btn.pressed.connect(on_new_template_pressed)
	template_tree.item_selected.connect(_on_template_item_selected)
	add_tag_ln_edt.timer_finished.connect(on_search_timer_timeout)
	SingletonManager.TagIt.group_created.connect(_on_group_created)
	SingletonManager.TagIt.group_deleted.connect(_on_group_deleted)


func input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_text_delete"):
		if tags_tree.has_focus():
			var current: TreeItem = tags_tree.get_next_selected(null)
			
			if current != null:
				_on_field_edited()
			
			while current != null:
				var next: TreeItem = tags_tree.get_next_selected(current)
				current.free()
				current = next
			
			get_viewport().set_input_as_handled()
		elif template_tree.has_focus():
			var current: TreeItem = template_tree.get_selected()
			if current != null:
				var confirmation := MessageConfirmationDialog.new()
				add_child(confirmation)
				confirmation.ok_button_text = "Delete"
				confirmation.title = "Confirm Delete..."
				confirmation.message = "Delete preset?"
				confirmation.show()
				var response: bool = await confirmation.dialog_finished
				if response:
					var uuid: String = current.get_metadata(0)
					on_template_deleted(uuid)
					template_resource.save()
				confirmation.queue_free()
			get_viewport().set_input_as_handled()


func _sort_groups_array(a: Array, b: Array) -> bool:
	return a[1].naturalnocasecmp_to(b[1]) < 0


func _on_title_changed(text: String) -> void:
	current_template.set_text(0, text.strip_edges())
	_on_field_edited()


func _on_search_group_text_changed(text: String) -> void:
	var clean_text: String = text.strip_edges().to_upper()
	for group in group_tree.get_root().get_children():
		group.visible = clean_text.is_empty() or group.get_text(0).containsn(clean_text)


func _on_search_template_text_changed(text: String) -> void:
	var clean_text: String = text.strip_edges().to_upper()
	for template in template_tree.get_root().get_children():
		template.visible = clean_text.is_empty() or template.get_text(0).containsn(clean_text)


func _on_group_created(group_id: int, group_name: String) -> void:
	var new_group: TreeItem = group_tree.get_root().create_child()
	new_group.set_text(0, group_name)
	new_group.set_metadata(0, group_id)
	var search_text: String = search_group_ln_edt.text.strip_edges().to_upper()
	new_group.visible = search_text.is_empty() or group_name.containsn(search_text)


func _on_group_deleted(group_id: int) -> void:
	for group in group_tree.get_root().get_children():
		if group.get_metadata(0) == group_id:
			group.free()
			break


func _on_group_edited() -> void:
	_on_field_edited()


func _on_template_item_selected() -> void:
	var item: TreeItem = template_tree.get_selected()
	if template_edited and loaded_template != null:
		save_current_template()
	current_template = item
	clear_fields()
	load_template(current_template.get_metadata(0))
	clear_thumbnail.disabled = thumbnail_container.texture == null


func _on_field_edited(_arg: Variant = null) -> void:
	if not template_edited:
		template_edited = true
		something_changed.emit()


func _on_tree_focus_lost(tree: Tree) -> void:
	tree.deselect_all()


func _on_tag_text_submitted(text: String) -> void:
	var clean_text: String = text.strip_edges().to_lower()
	add_tag_ln_edt.clear()
	if clean_text.is_empty():
		return
	
	for existing in tags_tree.get_root().get_children():
		if existing.get_text(0) == clean_text:
			return
	
	add_tag(clean_text)
	_on_field_edited()


func add_tag(tag: String) -> void:
	var new_tag: TreeItem = tags_tree.get_root().create_child()
	new_tag.set_text(0, tag)


func _on_select_thumbnail_pressed() -> void:
	var image_selector := FileDialog.new()
	add_child(image_selector)
	image_selector.add_filter("*.jpg,*.png,*.wepb", "Images")
	image_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	image_selector.access = FileDialog.ACCESS_FILESYSTEM
	image_selector.use_native_dialog = true
	image_selector.file_selected.connect(on_image_selected.bind(image_selector))
	image_selector.canceled.connect(on_cancelled.bind(image_selector))
	image_selector.show()


func _on_clear_thumbnail_pressed() -> void:
	if thumbnail_container.texture != null:
		thumbnail_container.texture = null
		_on_field_edited()
		clear_thumbnail.disabled = true
		loaded_template.set_thumbnail(null)


func set_groups_editable(set_editable: bool) -> void:
	if group_tree.get_root().get_child_count() == 0 or group_tree.get_root().get_child(0).is_editable(0) == set_editable:
		return
	
	for group in group_tree.get_root().get_children():
		group.set_editable(0, set_editable)


func on_image_selected(file_path: String, dialog: FileDialog) -> void:
	var image := Image.load_from_file(file_path)
	SingletonManager.TagIt.resize_image(image)
	var texture := ImageTexture.create_from_image(image)
	thumbnail_container.texture = texture
	clear_thumbnail.disabled = false
	loaded_template.set_thumbnail(texture)
	
	_on_field_edited()
	dialog.queue_free()


func on_cancelled(dialog: FileDialog) -> void:
	dialog.queue_free()


func on_new_template_pressed() -> void:
	create_template()


func create_template(template_name: String = "New Template") -> void:
	var uid: String = UUID.generate_new()
	var t: TagItTemplate = TagItTemplate.new()
	t._uuid = uid
	t.title = template_name
	all_templates[uid] = {"template": t, "edited": true}
	
	var new_template: TreeItem = template_tree.get_root().create_child()
	new_template.set_text(0, template_name)
	new_template.set_metadata(0, uid)


func on_template_deleted(deleted_uuid: String) -> void:
	if template_resource.has_template(deleted_uuid):
		template_resource.erase_template(deleted_uuid)
	all_templates.erase(deleted_uuid)
	
	if loaded_template._uuid == deleted_uuid:
		template_title.text = ""
		description_txt_edt.clear()
		clear_thumbnail.disabled = true
		clear_fields()
		current_template.free()
		current_template = null
		loaded_template = null
	
	for template in template_tree.get_root().get_children():
		if template.get_metadata(0) == deleted_uuid:
			template.free()
			break


func clear_fields() -> void:
	for tag in tags_tree.get_root().get_children():
		tag.free()
	add_tag_ln_edt.clear()
	for group in group_tree.get_root().get_children():
		group.set_checked(0, false)
	thumbnail_container.texture = null


func load_template(template_uuid: String) -> void:
	if not all_templates.has(template_uuid):
		var template: TagItTemplate = template_resource.get_template(template_uuid)
		all_templates[template_uuid] = {"template": template, "edited": false}
	
	var t: TagItTemplate = all_templates[template_uuid]["template"]
	template_title.text = t.title
	description_txt_edt.text = t.description
	thumbnail_container.texture = t.get_thumbnail()
	
	for tag in t.tags:
		var tax_exists: bool = false
		for tag_item in tags_tree.get_root().get_children():
			if Strings.nocasecmp_equal(tag, tag_item.get_text(0)):
				tax_exists = true
				break
		if not tax_exists:
			add_tag(tag)
	
	for group in t.groups:
		for group_item in group_tree.get_root().get_children():
			if group_item.get_metadata(0) == group:
				group_item.set_checked(0, true)
				break
	
	loaded_template = t


func save_current_template() -> void:
	var tags: Array[String] = []
	var groups: Array[int] = []
	
	for tag in tags_tree.get_root().get_children():
		tags.append(tag.get_text(0))
	
	for group in group_tree.get_root().get_children():
		if group.is_checked(0):
			groups.append(group.get_metadata(0))
	
	loaded_template.tags = tags
	loaded_template.groups = groups


func on_search_timer_timeout() -> void:
	var clean_text: String = add_tag_ln_edt.text.strip_edges().to_lower()
	var prefix: bool = clean_text.ends_with(DataManager.SEARCH_WILDCARD)
	var suffix: bool = clean_text.begins_with(DataManager.SEARCH_WILDCARD)
	
	add_tag_ln_edt.clear_list()
	
	if prefix:
		clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD).strip_edges(true, false)
	if suffix:
		clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD).strip_edges(false, true)
	
	while clean_text.begins_with(DataManager.SEARCH_WILDCARD):
		clean_text = clean_text.trim_prefix(DataManager.SEARCH_WILDCARD).strip_edges(true, false)
	
	while clean_text.ends_with(DataManager.SEARCH_WILDCARD):
		clean_text = clean_text.trim_suffix(DataManager.SEARCH_WILDCARD).strip_edges(false, true)
	
	if clean_text.is_empty():
		return
	
	var results: PackedStringArray = []
	
	if prefix and suffix:
		results = SingletonManager.TagIt.search_for_tag_contains(clean_text, add_tag_ln_edt.item_limit, true)
	elif suffix:
		results = SingletonManager.TagIt.search_for_tag_suffix(clean_text, add_tag_ln_edt.item_limit, true)
	else:
		results = SingletonManager.TagIt.search_for_tag_prefix(clean_text, add_tag_ln_edt.item_limit, true)
	
	if not results.is_empty():
		for tag in results:
			add_tag_ln_edt.add_item(
				tag,
				SingletonManager.TagIt.get_alias_name(tag) if SingletonManager.TagIt.has_alias(SingletonManager.TagIt.get_tag_id(tag)) else "")
		add_tag_ln_edt.show_items()


func insert_tree_group_sorted(item_text: String, item_id: int) -> void:
	var target_index: int = 0
	
	for item in group_tree.get_root().get_children():
		# We look through the items until we find the correct index
		if item.get_text(0).naturalnocasecmp_to(item_text) > 0:
			break
		else:
			target_index += 1
	
	# We don't create the item until now to possibly save 1 loop.
	var new_item: TreeItem = group_tree.get_root().create_child()
	new_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	
	new_item.set_text(0, item_text)
	
	new_item.set_metadata(0, item_id)
	
	new_item.set_editable(0, true)
	
	if target_index != new_item.get_index(): # We need to move it
		if target_index == 0:
			new_item.move_before(group_tree.get_root().get_child(0))
		else:
			new_item.move_after(group_tree.get_root().get_child(target_index - 1))


func on_save_pressed() -> void:
	if loaded_template != null:
		save_current_template()
	
	for template_id in all_templates:
		var data: Dictionary = all_templates[template_id]
		if not data["edited"]:
			continue
		var t: TagItTemplate = data["template"]
		if t.thumbnail_updated():
			t.update_thumbnail()
		template_resource.save_template(t)
		data["edited"] = false
	
	template_resource.save()
