extends HBoxContainer

const MessageConfirmationDialog = preload("res://scenes/dialogs/message_confirmation_dialog.gd")

const TOOL_ID: String = "templates"
var template_memory: Array[Dictionary] = []
var tool_description: String = "Create tag list templates."
var requires_save: bool = true
var current_template: int = -1:
	set(new_current):
		current_template = new_current
		var valid_id: bool = 0 <= new_current
		add_tag_ln_edt.editable = valid_id
		#search_group_ln_edt.editable = valid_id
		template_title.editable = valid_id
		description_txt_edt.editable = valid_id
		select_thumb_button.disabled = not valid_id
		select_thumb_button.disabled = not valid_id
		set_groups_editable(valid_id)
		if not valid_id:
			template_edited = false
var template_index: int = -1
var template_edited: bool = false:
	set(is_edited):
		if template_edited and current_template < 0:
			template_edited = false
		else:
			template_edited = is_edited

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



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	template_tree.create_item()
	group_tree.create_item()
	tags_tree.create_item()
	
	var templates := TemplateResource.get_templates()
	
	for template in templates.templates:
		var new_template: TreeItem = template_tree.get_root().create_child()
		new_template.set_text(0, template["title"])
	
	var groups: Dictionary = TagIt.get_tag_groups()
	
	for group_id in groups:
		var new_group: TreeItem = group_tree.get_root().create_child()
		new_group.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_group.set_text(0, groups[group_id]["name"])
		new_group.set_metadata(0, group_id)
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
	TagIt.group_created.connect(_on_group_created)
	TagIt.group_deleted.connect(_on_group_deleted)


func _input(_event: InputEvent) -> void:
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
					var current_idx: int = current.get_index()
					current.free()
					var templates := TemplateResource.get_templates()
					templates.erase_template(current_idx)
					templates.save()
					on_template_deleted(current_idx)
				confirmation.queue_free()
			get_viewport().set_input_as_handled()


func _on_title_changed(text: String) -> void:
	template_tree.get_root().get_child(current_template).set_text(0, text.strip_edges())
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
	if template_edited:
		save_current_template(current_template)
	current_template = item.get_index()
	clear_fields()
	load_template(current_template)
	clear_thumbnail.disabled = thumbnail_container.texture == null
	template_edited = false


func _on_field_edited(_arg: Variant = null) -> void:
	if not template_edited:
		template_edited = true
		print("k")


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


func set_groups_editable(set_editable: bool) -> void:
	if group_tree.get_root().get_child_count() == 0 or group_tree.get_root().get_child(0).is_editable(0) == set_editable:
		return
	
	for group in group_tree.get_root().get_children():
		group.set_editable(0, set_editable)


func on_image_selected(file_path: String, dialog: FileDialog) -> void:
	var image := Image.load_from_file(file_path)
	TagIt.resize_image(image)
	var texture := ImageTexture.create_from_image(image)
	#thumbnails[current_template] = texture
	thumbnail_container.texture = texture
	clear_thumbnail.disabled = false
	_on_field_edited()
	dialog.queue_free()


func on_cancelled(dialog: FileDialog) -> void:
	dialog.queue_free()


func on_new_template_pressed() -> void:
	var index_position: int = template_tree.get_root().get_child_count()
	template_memory.append({
		"title": "New Template",
		"description": "",
		"tags": Array([], TYPE_STRING, &"", null),
		"groups": Array([], TYPE_INT, &"", null),
		"thumbnail": null,
		"template_index": -1,
		"search_index": index_position})
	var new_template: TreeItem = template_tree.get_root().create_child()
	new_template.set_text(0, "New Template")


func on_template_deleted(deleted_index: int) -> void:
	for template in template_memory:
		if deleted_index < template["template_index"]:
			template["template_index"] -= 1
	
	if deleted_index == current_template:
		template_title.clear()
		description_txt_edt.clear()
		clear_thumbnail.disabled = true
		clear_fields()
		current_template = -1
	
	var templates := TemplateResource.get_templates()
	templates.delete_template_thumbnail(deleted_index)
	templates.erase_template(deleted_index)
	templates.save()


func clear_fields() -> void:
	for tag in tags_tree.get_root().get_children():
		tag.free()
	add_tag_ln_edt.clear()
	for group in group_tree.get_root().get_children():
		group.set_checked(0, false)
	thumbnail_container.texture = null


func load_template(template_idx: int) -> void:
	for template in template_memory:
		if template["search_index"] == template_idx:
			template_title.text = template["title"]
			description_txt_edt.text = template["description"]
			for tag in template["tags"]:
				var tax_exists: bool = false
				for tag_item in tags_tree.get_root().get_children():
					if Strings.nocasecmp_equal(tag, tag_item.get_text(0)):
						tax_exists = true
						break
				if not tax_exists:
					add_tag(tag)
			for group in template["groups"]:
				for group_item in group_tree.get_root().get_children():
					if group_item.get_metadata(0) == group:
						group_item.set_checked(0, true)
						break
			if template["thumbnail"] != null:
				thumbnail_container.texture = template["thumbnail"]
			template_index = template["template_index"]
			return
	
	var templates := TemplateResource.get_templates()
	var template_dict: Dictionary = templates.get_template(template_idx)
	
	template_title.text = template_dict["title"]
	description_txt_edt.text = template_dict["description"]
	template_index = template_idx
	
	for tag in template_dict["tags"]:
		var tax_exists: bool = false
		for tag_item in tags_tree.get_root().get_children():
			if Strings.nocasecmp_equal(tag, tag_item.get_text(0)):
				tax_exists = true
				break
		if not tax_exists:
			add_tag(tag)
	
	for group in template_dict["groups"]:
		for group_item in group_tree.get_root().get_children():
			if group_item.get_metadata(0) == group:
				group_item.set_checked(0, true)
				break
	
	if not template_dict["thumbnail"].is_empty() and FileAccess.file_exists(TemplateResource.get_thumbnail_path() + template_dict["thumbnail"]):
		var img := Image.load_from_file(TemplateResource.get_thumbnail_path() + template_dict["thumbnail"])
		var text := ImageTexture.create_from_image(img)
		thumbnail_container.texture = text


func save_current_template(search_idx: int) -> void:
	var tags: Array[String] = []
	var groups: Array[int] = []
	
	for tag in tags_tree.get_root().get_children():
		tags.append(tag.get_text(0))
	for group in group_tree.get_root().get_children():
		if group.is_checked(0):
			groups.append(group.get_metadata(0))
	
	var template_saved: bool = false
	
	for template in template_memory:
		if template["search_index"] == search_idx:
			template["title"] = template_title.text.strip_edges()
			template["description"] = description_txt_edt.text.strip_edges()
			template["tags"] = tags
			template["groups"] = groups
			template["thumbnail"] = thumbnail_container.texture.duplicate() if thumbnail_container.texture != null else null
			template["template_index"] = template_index
			template_saved = true
			break
	
	if not template_saved:
		template_memory.append({
			"title": template_title.text.strip_edges(),
			"description": description_txt_edt.text.strip_edges(),
			"tags": tags,
			"groups": groups,
			"thumbnail": thumbnail_container.texture.duplicate() if thumbnail_container.texture != null else null,
			"template_index": template_index,})
		


func on_save_pressed() -> void:
	var target_resource := TemplateResource.get_templates()
	if current_template != -1 and template_edited:
		save_current_template(current_template)
		template_edited = false
	
	for mem_template in template_memory:
		if mem_template["template_index"] == -1:
			var image_title: String = Strings.random_string64()
			var img: Image = mem_template["thumbnail"].get_image()
			img.save_jpg("user://templates/thumbnails/" + image_title + ".jpg")
			target_resource.new_template(
					mem_template["title"],
					mem_template["description"],
					mem_template["tags"],
					mem_template["groups"],
					image_title + ".jpg"
					)
		else:
			var img_path: String = target_resource.templates[mem_template["template_index"]]["thumbnail"]
			
			if mem_template["thumbnail"] == null:
				OS.move_to_trash(TemplateResource.get_thumbnail_path() + img_path)
				img_path = ""
			else:
				var img: Image = mem_template["thumbnail"].get_image()
				img.save_jpg(TemplateResource.get_thumbnail_path() + img_path)
			
			target_resource.overwrite_template(
				mem_template["template_index"],
				mem_template["title"],
					mem_template["description"],
					mem_template["tags"],
					mem_template["groups"],
					img_path)
	
	target_resource.save()
	target_resource.save()
	template_memory.clear()
