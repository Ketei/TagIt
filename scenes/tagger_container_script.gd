extends PanelContainer


signal search_in_wiki_pressed(tag: String)
signal list_changed

enum MediaStatus {
	PLAYING,
	PAUSED,
	STOPPED,
}

enum MediaType {
	NONE,
	IMAGE,
	GIF,
	VIDEO
	}

var _undo: UndoRedo = UndoRedo.new()
var lists: Dictionary[String, TagList] = {}
var shared_list: TagList = TagList.new()
var current_list: String = "":
	get():
		if 0 <= list_opt_btn.selected:
			return list_opt_btn.get_selected_metadata()
		return ""
var media_type: MediaType = MediaType.NONE:
	set(m):
		media_type = m
		match m:
			MediaType.IMAGE:
				project_image.visible = true
				gif_player.visible = false
				playback_controls.visible = false
				open_img_btn.visible = false
				clear_img_btn.visible = true
				reset_image_btn.visible = true
			MediaType.GIF:
				project_image.visible = false
				gif_player.visible = true
				playback_controls.visible = true
				open_img_btn.visible = false
				clear_img_btn.visible = true
				reset_image_btn.visible = true
			_:
				project_image.visible = false
				gif_player.visible = false
				playback_controls.visible = false
				open_img_btn.visible = true
				clear_img_btn.visible = false
				reset_image_btn.visible = false

var mouse_block: bool = false:
	set(b):
		mouse_block = b
		$MouseBlock.visible = b

var media_status: MediaStatus = MediaStatus.STOPPED:
	set(p):
		if p == media_status:
			return
		
		media_status = p
		
		match p:
			MediaStatus.PLAYING:
				play_pause_btn.tooltip_text = "Pause"
				play_pause_btn.icon = preload("res://icons/player-pause.svg")
				stop_btn.disabled = false
			MediaStatus.PAUSED:
				play_pause_btn.tooltip_text = "Play"
				play_pause_btn.icon = preload("res://icons/player-play.svg")
				stop_btn.disabled = false
			MediaStatus.STOPPED:
				play_pause_btn.tooltip_text = "Play"
				stop_btn.disabled = true
				play_pause_btn.icon = preload("res://icons/player-play.svg")

var image_changed: bool = false

# Suggestions not to be shown again for the session
var _suggestion_blacklist: Dictionary[String, Variant] = {}
var _group_blacklist: Dictionary[int, Variant] = {}
var custom_order_list: Dictionary[String, int] = {}

var tag_search_node: Control = null:
	set(n):
		if tag_search_node != null:
			tag_search_node.tags_selected.disconnect(_on_searcher_tags_selected)
		tag_search_node = n
		if n != null:
			n.tags_selected.connect(_on_searcher_tags_selected)

var prioritizer_node: Control = null:
	set(c):
		if prioritizer_node != null:
			prioritizer_node.close_pressed.disconnect(_on_prioritizer_close_pressed)
			c.updated.disconnect(_on_prioritizer_updated)
		prioritizer_node = c
		if c != null:
			c.close_pressed.connect(_on_prioritizer_close_pressed)
			c.updated.connect(_on_prioritizer_updated)

var sorting_node: Control = null

# --- List ---
@onready var list_selector_container: HBoxContainer = $MainMargin/Containers/TagsContainer/CurrentTagsContainer/AltSelectContainer
@onready var list_version_container: HBoxContainer = $MainMargin/Containers/EndContainer/TagsField/ListVersionContainer
@onready var delete_list_btn: Button = $MainMargin/Containers/TagsContainer/CurrentTagsContainer/AltSelectContainer/DeleteAltListBtn

@onready var add_tag_ln_edt: LineEdit = $MainMargin/Containers/TagsContainer/CurrentTagsContainer/BarItems/AddTagLnEdt
@onready var list_opt_btn: OptionButton = $MainMargin/Containers/TagsContainer/CurrentTagsContainer/AltSelectContainer/AltOptBtn
@onready var gen_version_opt_btn: OptionButton = $MainMargin/Containers/EndContainer/TagsField/ListVersionContainer/GenerateVersionOptBtn
@onready var generate_list_btn: Button = $MainMargin/Containers/EndContainer/TagsField/BtnCotnainer/GenerateBtn
@onready var site_opt_btn: OptionButton = $MainMargin/Containers/EndContainer/TagsField/BtnCotnainer/SiteOptBtn

@onready var tags_tree: Tree = $MainMargin/Containers/TagsContainer/CurrentTagsContainer/TagsTree
@onready var suggestion_tags: Tree = $MainMargin/Containers/TagsContainer/SuggestionContainer/SuggestionTree
@onready var groups_tree: Tree = $MainMargin/Containers/TagsContainer/SuggestionContainer/GroupsTree
# ------------

# --- Image Viewer ---
@onready var scroll_zoom_view: ScrollZoomView = $MainMargin/Containers/EndContainer/ImageContainer/PanelContainer/ScrollZoomView
@onready var project_image: TextureRect = $MainMargin/Containers/EndContainer/ImageContainer/PanelContainer/ScrollZoomView/Viewer/ProjectImage
@onready var gif_player: GifTextureRect = $MainMargin/Containers/EndContainer/ImageContainer/PanelContainer/ScrollZoomView/Viewer/GIFPlayer

@onready var open_img_btn: Button = $MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/OpenImgBtn
@onready var clear_img_btn: Button = $MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/ClearImgBtn
@onready var reset_image_btn: Button = $MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/ResetImageBtn

@onready var playback_controls: HBoxContainer = $MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/PlaybackControls

@onready var play_pause_btn: Button = $MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/PlaybackControls/PlayPauseBtn
@onready var stop_btn: Button = $MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/PlaybackControls/StopBtn
# --------------------

# --- Result ---
@onready var copy_btn: Button = $MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/ButtonsContainer/CopyBtn
@onready var tags_label: RichTextLabel = $MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/TextPanel/TextMargin/TagsLabel
@onready var formatter_opt_btn: OptionButton = $MainMargin/Containers/EndContainer/TagsField/BtnCotnainer/SiteOptBtn
@onready var change_prio_btn: Button = $MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/ButtonsContainer/ChangePrioBtn
@onready var export_list_btn: Button = $MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/ButtonsContainer/ExportBtn
# --------------

# --- Alt Wizard ---
@onready var alt_wizard: Control = $AltWizard
@onready var main_list_ln: LineEdit = $AltWizard/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/MainListLn
@onready var alt_list_ln: LineEdit = $AltWizard/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer3/AltListLn
@onready var shared_tags_tree: Tree = $AltWizard/PanelContainer/MarginContainer/VBoxContainer/SharedTagsTree
@onready var cancel_alts_btn: Button = $AltWizard/PanelContainer/MarginContainer/VBoxContainer/ButtonContainer/CancelAltsBtn
@onready var create_alts_btn: Button = $AltWizard/PanelContainer/MarginContainer/VBoxContainer/ButtonContainer/CreateAltsBtn
# ------------------


@onready var search_tag_btn: Button = $MainMargin/Containers/TagsContainer/CurrentTagsContainer/BarItems/SearchTagBtn


func _ready() -> void:
	# --- Visual Setup ---
	reset_image_btn.visible = false
	playback_controls.visible = false
	clear_img_btn.visible = false
	list_selector_container.visible = false
	list_version_container.visible = false
	# --------------------
	list_opt_btn.add_item("* Shared *", 0)
	list_opt_btn.set_item_metadata(0, "")
	list_opt_btn.select(0)
	
	add_tag_ln_edt.use_timer = SingletonManager.TagIt.settings.use_autofill
	
	generate_list_btn.disabled = SingletonManager.TagIt.get_site_count() == 0
	
	visibility_changed.connect(_on_visibility_changed)
	
	add_tag_ln_edt.timer_finished.connect(_on_search_timer_timeout)
	
	add_tag_ln_edt.text_submitted.connect(_on_tag_submited)
	open_img_btn.pressed.connect(_on_select_image_pressed)
	clear_img_btn.pressed.connect(_on_clear_project_image)
	reset_image_btn.pressed.connect(_on_reset_image_pressed)
	search_tag_btn.pressed.connect(_on_search_all_tags_pressed)
	
	list_opt_btn.item_selected.connect(_on_taglist_item_selected)
	
	play_pause_btn.pressed.connect(_on_play_pressed)
	stop_btn.pressed.connect(_on_stop_pressed)
	
	suggestion_tags.suggestions_activated.connect(_on_suggestions_activated)
	suggestion_tags.suggestions_deleted.connect(_on_suggestions_deleted)
	tags_tree.suggestions_dropped.connect(_on_suggestions_activated)
	
	tags_tree.groups_dropped.connect(_on_groups_dropped_on_tags)
	tags_tree.move_tags_to_new_list_pressed.connect(_on_move_tags_to_new_list_pressed)
	tags_tree.move_tags_to_list_pressed.connect(_on_move_tags_to_list_pressed)
	
	groups_tree.groups_deleted.connect(_on_groups_deleted)
	groups_tree.suggestions_activated.connect(_on_groups_suggestions_activated)
	
	copy_btn.pressed.connect(_on_copy_tags_btn_pressed)
	delete_list_btn.pressed.connect(_on_erase_tag_list_pressed)
	
	generate_list_btn.pressed.connect(generate_tag_list)
	change_prio_btn.pressed.connect(_on_open_prioritizer_pressed)
	export_list_btn.pressed.connect(_on_export_tags_pressed)
	
	tags_tree.search_in_wiki_pressed.connect(search_in_wiki_pressed.emit)
	
	SingletonManager.eSixAPI.suggestions_found.connect(_on_esix_api_suggestions_found)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.echo or not event.pressed:
			return
		
		if event.ctrl_pressed and not event.alt_pressed:
			if event.keycode == KEY_G:
				generate_tag_list()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_F:
				open_tag_searcher()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_Z:
				var current_focus: Control = get_viewport().gui_get_focus_owner()
				if current_focus is LineEdit:
					if current_focus.is_editing():
						return
				elif current_focus is TextEdit:
					if current_focus.editable:
						return
					
				if event.shift_pressed:
					if can_redo():
						redo()
				else:
					if can_undo():
						undo()
				get_viewport().set_input_as_handled()
				
			elif event.keycode == KEY_Y and not event.shift_pressed:
				var current_focus: Control = get_viewport().gui_get_focus_owner()
				if current_focus is LineEdit:
					if current_focus.is_editing():
						return
				elif current_focus is TextEdit:
					if current_focus.editable:
						return
					
				if can_redo():
					redo()
				get_viewport().set_input_as_handled()
		elif event.alt_pressed:
			if event.keycode == KEY_C:
				var focused_node: Control = get_viewport().gui_get_focus_owner()
				if focused_node is LineEdit:
					if focused_node.is_editing():
						return
				elif focused_node is TextEdit:
					if focused_node.editable:
						return
				copy_generated_tags()
				get_viewport().set_input_as_handled()
		else:
			if event.ctrl_pressed or event.alt_pressed:
				return
			
			var focused_node: Control = get_viewport().gui_get_focus_owner()
			if focused_node is LineEdit:
				if focused_node.is_editing():
					return
			elif focused_node is TextEdit:
				if focused_node.editable:
					return
			elif focused_node is Tree:
				if 0 < focused_node.get_root().get_child_count():
					return
			
			var printable: bool = 32 <= event.unicode and event.unicode != 127
			var deletion: bool = event.keycode == KEY_BACKSPACE or event.keycode == KEY_DELETE
			if printable or deletion:
				grab_tag_line_focus()


func set_tags_of_list(list_id: String, tags: Array, create: bool = false) -> void:
	if not list_id.is_empty() and not lists.has(list_id):
		if create:
			create_tag_list(list_id)
	
	var list: TagList = shared_list if list_id.is_empty() else lists.get(list_id)
	if list == null:
		return
	
	var on_selected: bool = current_list == list_id
	list.clear()
	if on_selected:
		tags_tree.clear_tags()
	
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		if list.add_tag(tag, id) and on_selected:
			_add_tag_to_tree(id, tag)


func restore_from_project(project: TagItProject) -> void:
	if project == null:
		return
	
	if project.shared_list.has_append():
		var img: Resource = project.shared_list.get_project_image()
		
		shared_list.image = img
		shared_list.origin_path = project.shared_list.get_project_image_path()
		shared_list.image_path = shared_list.origin_path
		
		if current_list == "":
			var type: String = project.shared_list.append_type()
			var type_en: MediaType = MediaType.NONE
			match type:
				"gif":
					type_en = MediaType.GIF
				"img":
					type_en = MediaType.IMAGE
			
			if type_en != media_type:
				match media_type:
					MediaType.IMAGE:
						project_image.texture = null
					MediaType.GIF:
						if gif_player.is_playing():
							gif_player.stop()
						gif_player.gif = null
				
				media_type = type_en
		
			match type_en:
				MediaType.IMAGE:
					project_image.texture = img
				MediaType.GIF:
					if media_status != MediaStatus.STOPPED:
						gif_player.stop()
						media_status = MediaStatus.STOPPED
					gif_player.gif = img
			scroll_zoom_view.reset_zoom()
	
	for list_id in project.lists:
		if not lists.has(list_id):
			continue
		
		var p_list: ProjectList = project.lists[list_id]
		if not p_list.has_append():
			continue
		var target: TagList = lists[list_id]
		var append: Resource = p_list.get_project_image()
		target.image = append
		target.origin_path = p_list.get_project_image_path()
		target.image_path = target.origin_path
		if current_list == list_id:
			var type: String = project.shared_list.append_type()
			var type_en: MediaType = MediaType.NONE
			match type:
				"gif":
					type_en = MediaType.GIF
				"img":
					type_en = MediaType.IMAGE
			
			if type_en != media_type:
				match media_type:
					MediaType.IMAGE:
						project_image.texture = null
					MediaType.GIF:
						if gif_player.is_playing():
							gif_player.stop()
						gif_player.gif = null
				
				media_type = type_en
		
			match type_en:
				MediaType.IMAGE:
					project_image.texture = append
				MediaType.GIF:
					if media_status != MediaStatus.STOPPED:
						gif_player.stop()
						media_status = MediaStatus.STOPPED
					gif_player.gif = append
			scroll_zoom_view.reset_zoom()


func load_project(project: TagItProject) -> void:
	if project == null:
		return
	
	clear()
	
	for tag in project.tag_blacklist:
		_suggestion_blacklist[tag] = null
	
	for group_id in project.group_blacklist:
		_group_blacklist[group_id] = null
	
	custom_order_list.assign(project.custom_priorities)
	
	var shared_path: String = project.shared_list.get_project_image_path()
	if not shared_path.is_empty():
		shared_list.image = project.shared_list.get_project_image()
		shared_list.origin_path = shared_path
		shared_list.image_path = shared_path
		
		var ext: String = shared_path.get_extension()
		if ext == "gif":
			shared_list.image_type = "gif"
			media_type = MediaType.GIF
			gif_player.gif = shared_list.image
		else:
			shared_list.image_type = "img"
			media_type = MediaType.IMAGE
			project_image.texture = shared_list.image
		
	for tag in project.shared_list.get_list_tags():
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		if shared_list.add_tag(tag, id):
			_add_tag_to_tree(id, tag)
	
	for suggestion in project.shared_list.get_suggestion_list():
		if shared_list.add_suggestion(suggestion):
			_add_suggestion_to_tree(suggestion)
	
	var groups: Dictionary = project.shared_list.get_groups()
	for group_id in groups:
		var tags: Dictionary[int, String] = {}
		for tag in groups[group_id]["tags"]:
			var id: int = SingletonManager.TagIt.get_tag_id(tag)
			if id <= 0:
				continue
			tags[id] = tag
			
		_add_group_entries_to_tree(
				group_id,
				groups[group_id]["title"],
				tags)
	
	for list_id in project.lists:
		var list: ProjectList = project.get_list(list_id)
		if not create_tag_list(list_id, false):
			continue
		
		var target: TagList = lists[list_id]
		var img_path: String = list.get_project_image_path()
		if not img_path.is_empty():
			target.image = list.get_project_image()
			target.origin_path = list.get_project_image_path()
			target.image_path = target.origin_path
			var ext: String = img_path.get_extension()
			if ext == "gif":
				target.image_type = "gif"
			else:
				target.image_type = "img"
		
		for tag in list.get_list_tags():
			var id: int = SingletonManager.TagIt.get_tag_id(tag)
			target.add_tag(tag, id)
		
		for tag in list.get_suggestion_list():
			target.add_suggestion(tag)


func load_template(template: TagItTemplate) -> void:
	if template.tags.is_empty() and template.groups.is_empty():
		return
	
	var groups: Dictionary[int, Dictionary] = {}
	var groups_remove: Dictionary[int, Array] = {}
	var template_tags: Array[String] = []
	var list: TagList = lists.get(current_list, shared_list)
	
	if not template.groups.is_empty():
		var g_d: Dictionary = SingletonManager.TagIt.get_groups_and_tags(template.groups)
		
		for g_id in g_d:
			var source: Dictionary = g_d[g_id]
			var tags: Array[String] = []
			
			for tag_id in source["tags"]:
				var tag_text: String = source["tags"][tag_id]
				if groups_tree.group_has_tag(g_id, tag_text):
					continue
				tags.append(tag_text)
			
			var data: Dictionary[String, Variant] = {
				"title": source["group_name"],
				"tags": tags}
			
			groups[g_id] = data
			groups_remove[g_id] = tags.duplicate()
	
	if not template.tags.is_empty():
		for tag in template.tags:
			if list.has_text(tag):
				continue
			template_tags.append(tag)
	
	_undo.create_action("Load Tag Template")
	_undo.add_do_method(_do_load_template.bind(current_list, template_tags.duplicate(), groups))
	_undo.add_undo_method(_undo_load_template.bind(current_list, template_tags.duplicate(), groups_remove))
	_undo.commit_action()
	list_changed.emit()


func can_undo() -> bool:
	return _undo.has_undo()


func can_redo() -> bool:
	return _undo.has_redo()


func undo() -> void:
	if _undo.has_undo():
		_undo.undo()
		list_changed.emit()


func redo() -> void:
	if _undo.has_redo():
		_undo.redo()
		list_changed.emit()


func load_tag_list(list_id: String) -> bool:
	var new_list: TagList = lists.get(list_id, shared_list)
	if new_list == null:
		return false
	
	delete_list_btn.disabled = new_list == shared_list
	
	tags_tree.clear_tags()
	var tags: Dictionary = new_list.get_list_tags()
	for tag in tags:
		var tag_data: Dictionary = {}
		var tag_id: int = tags[tag]
		if 0 < tag_id:
			tag_data = SingletonManager.TagIt.get_tag_data_columns(tag_id, ["category_id", "tooltip"])
		
		var tooltip_data: Variant = tag_data.get("tooltip", "")
		var data_category: int = tag_data.get("category_id", 0)
		var icon: Texture2D = null
		var color: Color = Color.WHITE
		if 0 < data_category:
			icon = SingletonManager.TagIt.get_icon_texture(data_category)
			color = SingletonManager.TagIt.get_category_icon_color(data_category)
		
		tags_tree.add_tag(
				tag_id,
				tag,
				"" if tooltip_data == null else tooltip_data,
				icon,
				data_category,
				color)
		if not current_list.is_empty() and shared_list.has_text(tag): # We're not at the base
			tags_tree.set_tag_text_color(tag, Color.DARK_GRAY)
	
	suggestion_tags.clear_suggestions()
	for suggestion in new_list._suggestions:
		suggestion_tags.add_suggestion(suggestion)
	
	if new_list.image_type.is_empty():
		if media_type != MediaType.NONE:
			match media_type:
				MediaType.IMAGE:
					project_image.texture = null
				MediaType.GIF:
					if gif_player.is_playing():
						gif_player.stop()
			media_type = MediaType.NONE
	else:
		var target_media: MediaType = MediaType.NONE
		
		match new_list.image_type:
			"img":
				target_media = MediaType.IMAGE
			"gif":
				target_media = MediaType.GIF
		
		if target_media != media_type:
			match media_type:
				MediaType.IMAGE:
					project_image.texture = null
				MediaType.GIF:
					if gif_player.is_playing():
						gif_player.stop()
					gif_player.gif = null
			
			media_type = target_media
		
		match target_media:
			MediaType.IMAGE:
				project_image.texture = new_list.image
			MediaType.GIF:
				if media_status != MediaStatus.STOPPED:
					gif_player.stop()
					media_status = MediaStatus.STOPPED
				gif_player.gif = new_list.image
		scroll_zoom_view.reset_zoom()
	return true


func save_current_list() -> void:
	var list: TagList = lists.get(current_list, shared_list)
	if list == null:
		return
	
	list.clear()
	var entries: Dictionary = tags_tree.get_used_tags() # [String, int]
	for tag_text:String in entries:
		list.add_tag(tag_text, entries[tag_text])


func generate_tag_list() -> void:
	var common_tags: Dictionary[String, int] = shared_list.get_list_tags()
	
	if -1 < gen_version_opt_btn.selected:
		var selected_list: TagList = lists.get(gen_version_opt_btn.get_selected_metadata())
		if selected_list != null:
			common_tags.merge(selected_list.get_list_tags())
	
	var id_tags: Dictionary[String, int] = {}
	var clear_tags: Array[String] = []
	for tag in common_tags:
		var id: int = common_tags[tag]
		if 0 < id:
			id_tags[tag] = id
		else:
			clear_tags.append(tag)
	
	var ids: Array[int] = Arrays.create_typed(TYPE_INT, id_tags.values())
	
	var final_tag_ids: Array = SingletonManager.TagIt.get_final_tag_ids(ids)
	var sorted_tags: Dictionary = SingletonManager.TagIt.sort_tag_ids_by_priority(final_tag_ids)
	if not sorted_tags.has(0):
		sorted_tags[0] = Arrays.create_typed(TYPE_INT)
	
	# --- Preparing for custom order ---
	var named_ids: Dictionary[String, int] = {}
	var use_prefixes: bool = SingletonManager.TagIt.site_uses_prefixes(site_opt_btn.get_selected_website_id())
	
	for priority in sorted_tags:
		# ID: Name
		var tag_names: Dictionary = SingletonManager.TagIt.get_tags_name(sorted_tags[priority], use_prefixes)
		
		for tag_id in tag_names:
			var tag_text: String = tag_names[tag_id]
			if custom_order_list.has(tag_text):
				named_ids[tag_text] = custom_order_list[tag_text]
			else:
				named_ids[tag_names[tag_id]] = priority
	
	for tag in clear_tags:
		if custom_order_list.has(tag):
			named_ids[tag] = custom_order_list[tag]
		else:
			named_ids[tag] = 0
	
	# --- Custom order applied ---
	
	# --- Cramming into a dictionary Priority:[text, tags] ---
	var tag_priorities: Dictionary[int, Array] = {}
	
	for tag_name in named_ids:
		var priority: int = named_ids[tag_name]
		if not tag_priorities.has(priority):
			tag_priorities[priority] = Arrays.create_typed(TYPE_STRING)
		tag_priorities[priority].append(tag_name)
	
	# --- Crammed ---
	
	var priorities: Array = tag_priorities.keys()
	priorities.sort_custom(Arrays.sort_custom_desc)
	var tags_array: Array[String] = []
	
	for priority in tag_priorities:
		tags_array.append_array(tag_priorities[priority])
	
	var website_data: Dictionary = SingletonManager.TagIt.get_site_formatting(formatter_opt_btn.get_selected_website_id())
	
	for tag_idx in range(tags_array.size()):
		tags_array[tag_idx] = tags_array[tag_idx].replace(" ", website_data["whitespace"])
	
	tags_label.text = website_data["separator"].join(tags_array)


func create_tag_list(list_id: String, duplicate_suggestions: bool = true) -> bool:
	if lists.has(list_id):
		return false
	
	var new_list: TagList = TagList.new()
	var title_id: String = Strings.capitalize(list_id)
	
	if duplicate_suggestions:
		var current: TagList = lists.get(current_list, shared_list)
		new_list._suggestions.assign(current._suggestions)
	
	lists[list_id] = new_list
	
	list_opt_btn.add_item(title_id)
	list_opt_btn.set_item_metadata(-1, list_id)
	
	gen_version_opt_btn.add_item(title_id)
	gen_version_opt_btn.set_item_metadata(-1, list_id)
	
	if not list_selector_container.visible:
		list_selector_container.visible = true
	if not list_version_container.visible:
		list_version_container.visible = true
	
	tags_tree.add_alt_list(title_id, list_id)
	
	return true


func create_tag_list_with_undo(list_id: String) -> bool:
	if lists.has(list_id):
		return false
	_undo.create_action("Create Alt List")
	_undo.add_do_method(_do_create_tag_list.bind(list_id))
	_undo.add_undo_method(_undo_create_tag_list.bind(list_id))
	_undo.commit_action()
	list_changed.emit()
	return true


func _do_create_tag_list(list_id: String) -> void:
	if lists.has(list_id):
		return
	create_tag_list(list_id, false)


func _undo_create_tag_list(list_id: String) -> void:
	if not lists.has(list_id):
		return
	erase_tag_list(list_id)


func erase_tag_list(list_id: String) -> bool:
	if not lists.has(list_id):
		return false
	
	# id: Title
	var list_items: Dictionary[String, String] = {}
	var prev_selected: String = current_list
	var select_shared: bool = current_list == list_id
	
	for idx in list_opt_btn.item_count:
		list_items[list_opt_btn.get_item_metadata(idx)] = list_opt_btn.get_item_text(idx)
	
	list_items.erase(list_id)
	var ids: Array = list_items.keys()
	
	list_opt_btn.clear()
	for id in list_items:
		list_opt_btn.add_item(list_items[id])
		list_opt_btn.set_item_metadata(-1, id)
	
	if select_shared:
		list_opt_btn.select(0)
		load_tag_list("")
	else:
		list_opt_btn.select(ids.find(prev_selected))
	
	var generators: Dictionary[String, String] = {}
	for idx in gen_version_opt_btn.item_count:
		generators[gen_version_opt_btn.get_item_metadata(idx)] = gen_version_opt_btn.get_item_text(idx)
	
	generators.erase(list_id)
	var new_gens: Array = generators.keys()
	var gen_selected: String = gen_version_opt_btn.get_selected_metadata()
	gen_version_opt_btn.clear()
	for id in generators:
		gen_version_opt_btn.add_item(generators[id])
		gen_version_opt_btn.set_item_metadata(-1, id)
	
	if 0 < gen_version_opt_btn.item_count:
		var new_idx: int = clampi(new_gens.find(gen_selected), 0, gen_version_opt_btn.item_count - 1)
		gen_version_opt_btn.select(new_idx)
	else:
		gen_version_opt_btn.select(-1)
	
	if lists.size() == 0:
		list_selector_container.visible = false
		list_version_container.visible = false
	
	tags_tree.delete_alt_list(list_id)
	
	return true


func launch_alt_wizard() -> void:
	var was_processing: bool = is_processing_input()
	if was_processing:
		set_process_input(false)
	
	mouse_block = true
	alt_wizard.visible = true
	
	alt_wizard.clear()
	alt_wizard.set_shared_tags(shared_list.get_list_tags().keys())
	alt_wizard.set_used_list_ids(lists.keys())
	
	var success: bool = await alt_wizard.wizard_finished
	if was_processing:
		set_process_input(true)
	mouse_block = false
	if not success:
		return
	
	var main_list: String = alt_wizard.get_main_list_id()
	var alt_list: String = alt_wizard.get_alt_list_id()
	var moved_tags: Array[String] = alt_wizard.get_selected_main()
	
	# Create both lists and the undo action
	_undo.create_action("Create Alt Lists")
	_undo.add_do_method(_do_create_wizard_lists.bind(main_list, alt_list, moved_tags.duplicate()))
	_undo.add_undo_method(_undo_create_wizard_lists.bind(main_list, alt_list, moved_tags.duplicate()))
	_undo.commit_action()
	
	for item in list_opt_btn.item_count:
		if list_opt_btn.get_item_metadata(item) == alt_list:
			list_opt_btn.select(item)
			break
	load_tag_list(alt_list)
	list_changed.emit()


func clear() -> void:
	list_opt_btn.clear()
	list_opt_btn.add_item("* Shared *", 0)
	list_opt_btn.set_item_metadata(0, "")
	list_opt_btn.select(0)
	
	gen_version_opt_btn.clear()
	
	tags_tree.clear_tags()
	suggestion_tags.clear_suggestions()
	groups_tree.clear_groups()
	
	shared_list.clear()
	for list in lists:
		lists[list].clear()
	lists.clear()
	
	_suggestion_blacklist.clear()
	_group_blacklist.clear()
	custom_order_list.clear()
	
	if media_type != MediaType.NONE:
		match media_type:
			MediaType.IMAGE:
				project_image.texture = null
			MediaType.GIF:
				gif_player.gif = null
		media_type = MediaType.NONE
	media_status = MediaStatus.STOPPED
	scroll_zoom_view.reset_zoom()
	
	tags_label.text = ""
	
	reset_image_btn.visible = false
	playback_controls.visible = false
	clear_img_btn.visible = false
	list_selector_container.visible = false
	list_version_container.visible = false
	
	if prioritizer_node != null:
		prioritizer_node.visible = false
	if tag_search_node != null:
		tag_search_node.visible = false


func get_groups_data() -> Dictionary[int, Dictionary]:
	var groups: Dictionary[int, Dictionary] = {}
	for group_id in groups_tree.get_all_groups():
		var data: Dictionary = groups_tree.get_group_data(group_id)
		var tags: Array[String] = []
		tags.assign(data["tags"].keys())
		
		groups[group_id] = {
			"title": data["title"],
			"tags": tags}
	return groups


func get_project_thumbnail_image() -> Texture2D:
	if not shared_list.image_type.is_empty():
		var type: String = shared_list.image_type
		if type == "img":
			return shared_list.image
		elif type == "gif":
			var frames: SpriteFrames = shared_list.image
			if 0 < frames.get_frame_count(&"gif"):
				return frames.get_frame_texture(&"gif", 0)
	
	if lists.size() == 0:
		return null
	
	for idx in range(1, list_opt_btn.item_count):
		var list: TagList = lists.get(list_opt_btn.get_item_metadata(idx))
		if list == null:
			continue
		
		var type: String = list.image_type
		if type.is_empty():
			continue
		
		if type == "img":
			return list.image
		elif type == "gif":
			var frames: SpriteFrames = shared_list.image
			if frames.get_frame_count(&"gif"):
				return frames.get_frame_texture(&"gif", 0)
	
	return null


func show_custom_sorting_window() -> void:
	if sorting_node != null and sorting_node.visible:
		return
	
	var processing: bool = is_processing_input()
	if processing:
		set_process_input(false)
	
	if sorting_node == null:
		sorting_node = preload("res://scenes/custom_sort_window.tscn").instantiate()
		add_child(sorting_node)
	
	sorting_node.set_custom_sorting(SingletonManager.TagIt.settings.custom_sorting)
	var result: Array = await sorting_node.custom_sort_finished
	sorting_node.visible = false
	
	if result[0]:
		SingletonManager.TagIt.settings.custom_sorting = result[1]
	
	if processing:
		set_process_input(true)


func sort_tags_custom() -> void:
	tags_tree.sort_tags_custom()


func sort_tags_alphabetical(ascending: bool = true) -> void:
	tags_tree.sort_tags_alphabetical(ascending)


func sort_tags_category(ascending: bool = true) -> void:
	tags_tree.sort_tags_category(ascending)


func set_image_from_path(path: String) -> void:
	var ext: String = path.get_extension()
	if not FileAccess.file_exists(path) or not DataManager.is_valid_append_format(ext):
		return
	
	var list: TagList = lists.get(current_list, shared_list)
	
	if ext == "gif":
		#var gif: GIFTexture = GIFTexture.load_from_file(file_path)
		var gif: SpriteFrames = GifManager.sprite_frames_from_file(path)
		if gif == null:
			return
		
		list.image = gif
		list.image_type = "gif"
		list.image_path = path
		media_type = MediaType.GIF
		gif_player.gif = gif
		gif_player.paused = false
	else:
		var resource: Image = Image.load_from_file(path)
		if resource == null:
			return
		
		list.image_type = "img"
		media_type = MediaType.IMAGE
		if gif_player.is_playing():
			gif_player.stop()
		
		var texture: ImageTexture = ImageTexture.create_from_image(resource)
		project_image.texture = texture
		list.image = texture
		list.image_path = path
		
	clear_img_btn.visible = true
	reset_image_btn.visible = true
	open_img_btn.visible = false
	scroll_zoom_view.reset_zoom()
	image_changed = true


func validate_site_count() -> void:
	generate_list_btn.disabled = SingletonManager.TagIt.get_site_count() == 0


func set_category_color(category: int, color: String) -> void:
	tags_tree.update_category_color(category, color)


func set_category_icon(category: int, icon: Texture2D) -> void:
	tags_tree.update_category_icon(category, icon)


func open_tag_searcher() -> void:
	if tag_search_node == null:
		tag_search_node = preload("res://scenes/all_tags_panel.tscn").instantiate()
		tag_search_node.panel_close_pressed.connect(_on_close_tag_searcher_pressed)
		add_child(tag_search_node)
	
	if not tag_search_node.visible:
		tag_search_node.visible = true
	tag_search_node.focus_main()


func copy_generated_tags() -> void:
	DisplayServer.clipboard_set(tags_label.text)


func grab_tag_line_focus(caret_to_end: bool = true) -> void:
	if mouse_block:
		return
	
	add_tag_ln_edt.grab_focus()
	if caret_to_end:
		add_tag_ln_edt.caret_column = add_tag_ln_edt.text.length()


func add_tags_from_action(action: String, tags: Array[String]) -> void:
	if tags.is_empty():
		return
	
	var list: TagList = lists.get(current_list, shared_list)
	var valid_tags: Array[String] = []
	
	for tag in tags:
		if list.has_text(tag):
			continue
		valid_tags.append(tag)
	
	if valid_tags.is_empty():
		return
	
	_undo.create_action(action)
	_undo.add_do_method(_do_add_tags.bind(current_list, valid_tags.duplicate()))
	_undo.add_undo_method(_undo_add_tags.bind(current_list, valid_tags.duplicate()))
	_undo.commit_action()
	list_changed.emit()


func get_current_list_image() -> Resource:
	var list: TagList = lists.get(current_list, shared_list)
	return list.image


func set_autofill(enabled: bool) -> void:
	add_tag_ln_edt.use_timer = enabled


func clean_undo() -> void:
	if is_instance_valid(_undo):
		_undo.free()


func _do_add_tags(on_list: String, tags: Array[String]) -> void:
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var update: bool = current_list == on_list
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		if list.add_tag(tag, id) and update:
			_add_tag_to_tree(id, tag)


func _undo_add_tags(on_list: String, tags: Array[String]) -> void:
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var update: bool = current_list == on_list
	for tag in tags:
		if list.remove_tag_text(tag) and update:
			tags_tree.remove_tag_from_text(tag)


func _on_visibility_changed() -> void:
	var tagger_visible: bool = is_visible_in_tree()
	scroll_zoom_view.set_process(tagger_visible)
	if tagger_visible:
		set_process_input(true)
		if media_type == MediaType.GIF and media_status == MediaStatus.PLAYING and gif_player.paused:
			gif_player.paused = false
	else:
		set_process_input(false)
		if media_type == MediaType.GIF and media_status == MediaStatus.PLAYING:
			gif_player.paused = true


func _do_load_template(on_list: String, tags: Array[String], groups: Dictionary[int, Dictionary]) -> void:
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var at_list: bool = on_list == current_list
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		if list.add_tag(tag, id) and at_list:
			_add_tag_to_tree(id, tag)
	
	for group_id in groups:
		var data: Dictionary = groups[group_id]
		_add_group_entries_to_tree(
				group_id,
				data["title"],
				data["tags"])


func _undo_load_template(on_list: String, tags: Array[String], groups: Dictionary[int, Array]) -> void:
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var at_list: bool = on_list == current_list
	for tag in tags:
		if list.remove_tag_text(tag) and at_list:
			tags_tree.remove_tag_from_text(tag)
	
	groups_tree.remove_data(groups)


func _do_create_wizard_lists(main: String, alt: String, tags_moved: Array[String]) -> void:
	create_tag_list(main)
	create_tag_list(alt)
	
	var main_list: TagList = lists.get(main)
	print("Moving tags: ", tags_moved)
	var on_shared: bool = current_list.is_empty()
	for tag in tags_moved:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		main_list.add_tag(tag, id)
		if shared_list.remove_tag_text(tag) and on_shared:
			print("Removing: ", tag)
			tags_tree.remove_tag_from_text(tag)


func _undo_create_wizard_lists(main: String, alt: String, tags: Array[String]) -> void:
	erase_tag_list(alt)
	erase_tag_list(main)
	
	var on_shared: bool = current_list.is_empty()
	for tag in tags:
		var tag_id: int = SingletonManager.TagIt.get_tag_id(tag)
		if shared_list.add_tag(tag, tag_id) and on_shared:
			_add_tag_to_tree(tag_id, tag)


func _on_searcher_tags_selected(tags: PackedStringArray) -> void:
	if tags.is_empty():
		return
	
	var list: TagList = lists.get(current_list, shared_list)
	
	if list == null:
		return
	
	var tag_ids: Array[int] = []
	var tags_to_add: Dictionary[String, int] = {}
	
	for tag in tags:
		var s_tag: String = tag
		var id: int = -1
		if SingletonManager.TagIt.has_tag(s_tag):
			s_tag = SingletonManager.TagIt.get_alias_name(s_tag)
			id = SingletonManager.TagIt.get_tag_id(s_tag)
		else:
			id = SingletonManager.TagIt.get_tag_id(tag)
		
		if 0 < id:
			tag_ids.append(id)
		if list.has_text(s_tag):
			continue
		tags_to_add[s_tag] = id
	
	if not tags_to_add.is_empty():
		var added: Array[String] = Arrays.create_typed(TYPE_STRING, tags_to_add.keys())
		_undo.create_action("Add Tags from Search")
		_undo.add_do_method(_do_add_search_tags.bind(added.duplicate(), current_list))
		_undo.add_undo_method(_undo_add_search_tags.bind(added.duplicate(), current_list))
		_undo.commit_action()
		list_changed.emit()
	
	var sugg_ids: Array = SingletonManager.TagIt.get_suggestions_for_tags(tag_ids)
	var suggestions: Dictionary = SingletonManager.TagIt.get_tags_name(sugg_ids) # id:Name
	
	for id in suggestions:
		if list.has_id(id):
			continue
		suggestion_tags.add_suggestion(suggestions[id])
	
	for added_item in tags_to_add:
		if suggestion_tags.has_suggestion(added_item):
			suggestion_tags.delete_tag(added_item)


func _do_add_search_tags(tags: Array[String], list: String) -> void:
	var list_obj: TagList = shared_list if list.is_empty() else lists.get(list)
	if list_obj == null:
		return
	
	var on_list: bool = list == current_list
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		
		if list_obj.add_tag(tag, id) and on_list:
			_add_tag_to_tree(id, tag)


func _undo_add_search_tags(tags: Array[String], list: String) -> void:
	var list_obj: TagList = shared_list if list.is_empty() else lists.get(list)
	if list_obj == null:
		return
	
	var on_list: bool = list == current_list
	for tag in tags:
		if list_obj.remove_tag_text(tag) and on_list:
			tags_tree.remove_tag_from_text(tag)


func _on_search_timer_timeout() -> void:
	if not add_tag_ln_edt.has_focus():
		return
	
	add_tag_ln_edt.clear_list()
	var clean_text: String = add_tag_ln_edt.text.strip_edges().to_lower()
	
	var prefix: bool = clean_text.ends_with(DataManager.SEARCH_WILDCARD)
	var suffix: bool = clean_text.begins_with(DataManager.SEARCH_WILDCARD)
	
	if prefix:
		clean_text = clean_text.lstrip(DataManager.SEARCH_WILDCARD).strip_edges(true, false)
	if suffix:
		clean_text = clean_text.rstrip(DataManager.SEARCH_WILDCARD).strip_edges(false, true)
	
	if clean_text.is_empty():
		return
	
	var results: PackedStringArray = []
	
	if prefix and suffix:
		results = SingletonManager.TagIt.search_for_tag_contains(clean_text, add_tag_ln_edt.item_limit, true)
	elif suffix:
		results = SingletonManager.TagIt.search_for_tag_suffix(clean_text, add_tag_ln_edt.item_limit, true)
	else:
		results = SingletonManager.TagIt.search_for_tag_prefix(clean_text, add_tag_ln_edt.item_limit, true)
	
	if results.is_empty():
		return
	
	var id_results: Array[int] = []
	var data: Dictionary = SingletonManager.TagIt.get_tags_ids(results)
	
	if not data.is_empty():
		id_results.assign(data.values())
	
	var tags_with_aliases: Dictionary = SingletonManager.TagIt.get_aliases_consequent_names_from(id_results)
	
	for tag in results:
		var tag_id: int = SingletonManager.TagIt.get_tag_id(tag)
		if tags_with_aliases.has(tag_id):
			var alias: String = tags_with_aliases[tag_id]
			add_tag_ln_edt.add_item(
					tag,
					alias)
		else:
			add_tag_ln_edt.add_item(tag)
	
	add_tag_ln_edt.show_items()


func _on_erase_tag_list_pressed() -> void:
	var list_to_erase: String = current_list
	var list_tags: Dictionary[String, int] = tags_tree.get_used_tags()
	var ver_idx: int = 0
	
	for item in gen_version_opt_btn.item_count:
		if gen_version_opt_btn.get_item_metadata(item) == list_to_erase:
			ver_idx = item
			break
	
	_undo.create_action("Erase List '%s'" % list_to_erase)
	_undo.add_do_method(_do_erase_tag_list.bind(list_to_erase))
	_undo.add_undo_method(_undo_erase_tag_list.bind(list_to_erase, list_opt_btn.selected, ver_idx, list_tags))
	_undo.commit_action()
	
	list_changed.emit()


func _undo_erase_tag_list(list_id: String, list_index:int, generator_index: int, list_tags: Dictionary[String, int]) -> void:
	if lists.has(list_id):
		return
	
	var selected: String = current_list
	var list_items: Array[String] = []
	
	for idx in list_opt_btn.item_count:
		list_items.append(list_opt_btn.get_item_metadata(idx))
	
	if list_items.is_empty():
		list_items.append(list_id)
	else:
		var index_insert: int = Arrays.clamp_index(list_items, list_index)
		list_items.insert(index_insert, list_id)
	
	list_opt_btn.clear()
	for item_idx in list_items.size():
		var text: String = list_items[item_idx]
		list_opt_btn.add_item(text, item_idx)
		list_opt_btn.set_item_metadata(item_idx, text)
	
	var new_selected: int = list_items.find(selected)
	if new_selected == -1:
		new_selected = list_items.find(list_id)
	
	var gen_selected: String = gen_version_opt_btn.get_selected_metadata() if -1 < gen_version_opt_btn.selected else ""
	var gen_items: Array[String] = []
	for idx in gen_version_opt_btn.item_count:
		gen_items.append(gen_version_opt_btn.get_item_metadata(idx))
	
	if gen_items.is_empty():
		gen_items.append(list_id)
	else:
		var index_insert: int = Arrays.clamp_index(gen_items, generator_index)
		gen_items.insert(index_insert, list_id)
	
	gen_version_opt_btn.clear()
	for idx in gen_items.size():
		gen_version_opt_btn.add_item(gen_items[idx], idx)
		gen_version_opt_btn.set_item_metadata(idx, gen_items[idx])
	
	var new_gen_select: int = gen_items.find(gen_selected)
	if new_gen_select == -1:
		new_gen_select = gen_items.find(list_id)
	
	gen_version_opt_btn.select(new_gen_select)
	
	var new_list: TagList = TagList.new()
	for tag_text in list_tags:
		new_list.add_tag(tag_text, list_tags[tag_text])
	
	lists[list_id] = new_list
	list_opt_btn.select(new_selected)
	
	if selected == list_items[new_selected]:
		return
	
	save_current_list()
	load_tag_list(list_items[new_selected])


func _do_erase_tag_list(to_erase: String) -> void:
	if not lists.has(to_erase):
		return
	
	erase_tag_list(to_erase)


func _on_taglist_item_selected(idx: int) -> void:
	load_tag_list(list_opt_btn.get_item_metadata(idx))


func _on_search_all_tags_pressed() -> void:
	open_tag_searcher()


func _on_close_tag_searcher_pressed() -> void:
	tag_search_node.visible = false
	tag_search_node.clear()
	tag_search_node.reset_position()


func _on_reset_image_pressed() -> void:
	scroll_zoom_view.reset_zoom()


func _on_select_image_pressed() -> void:
	mouse_block = true
	open_img_btn.disabled = true
	var img_selector: FileDialog = preload("uid://bllqgi0evgkgk").new()
	for type in DataManager.VALID_APPENDS:
		for format in DataManager.VALID_APPENDS[type]:
			img_selector.add_filter_extension(type, format)
	img_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	img_selector.access = FileDialog.ACCESS_FILESYSTEM
	img_selector.use_native_dialog = true
	img_selector.exclusive = true
	add_child(img_selector)
	img_selector.popup_centered()
	var result: Array = await img_selector.dialog_finished
	
	img_selector.queue_free()
	open_img_btn.disabled = false
	mouse_block = false
	
	if not result[0]:
		return
	
	set_image_from_path(result[1])
	list_changed.emit()


func _on_clear_project_image() -> void:
	if media_type == MediaType.NONE:
		return
	
	match media_type:
		MediaType.IMAGE:
			project_image.texture = null
		MediaType.GIF:
			gif_player.stop()
			gif_player.gif = null
	
	var list: TagList = lists.get(current_list, shared_list)
	list.image = null
	list.image_type = ""
	list.image_path = ""
	media_type = MediaType.NONE
	clear_img_btn.visible = false
	open_img_btn.visible = true
	reset_image_btn.visible = false
	image_changed = true
	list_changed.emit()


func _on_play_pressed() -> void:
	match media_status:
		MediaStatus.PLAYING: # Convert to pause
			media_status = MediaStatus.PAUSED
			if media_type == MediaType.GIF:
				gif_player.paused = true
		MediaStatus.STOPPED:
			media_status = MediaStatus.PLAYING
			if media_type == MediaType.GIF:
				if gif_player.paused:
					gif_player.paused = false
				gif_player.play()
		MediaStatus.PAUSED:
			if media_type == MediaType.GIF:
				media_status = MediaStatus.PLAYING
				gif_player.paused = false


func _on_stop_pressed() -> void:
	if media_type == MediaType.GIF:
		gif_player.stop()
		media_status = MediaStatus.STOPPED


func _on_tag_submited(text: String) -> void:
	var tag_text: String = text.strip_edges().to_lower()
	add_tag_ln_edt.clear()
	
	if tag_text.is_empty():
		return
	
	var list: TagList = lists.get(current_list, shared_list)
	
	if list == null or list.has_text(tag_text):
		return
	
	
	if SingletonManager.TagIt.has_tag(tag_text):
		tag_text = SingletonManager.TagIt.get_alias_name(tag_text)
	
	_undo.create_action("Add Tag '%s'" % tag_text)
	_undo.add_do_method(_do_add_tag.bind(tag_text, current_list))
	_undo.add_undo_method(_undo_add_tag.bind(tag_text, current_list))
	_undo.commit_action()
	list_changed.emit()
	
	var tag_id: int = SingletonManager.TagIt.get_tag_id(tag_text)
	
	# --- Lookup for Online Suggestions ---
	if SingletonManager.TagIt.settings.request_suggestions:
		SingletonManager.eSixAPI.search_suggestions(tag_text, current_list)
	# -------------------------------------
	
	if tag_id <= 0:
		return
	
	# --- Add Local Suggestions ---
	var sugg_id: Array[int] = SingletonManager.TagIt.get_suggestions(tag_id)
	var suggestions: Dictionary = SingletonManager.TagIt.get_tags_name(sugg_id) # id:Name
	for id in suggestions:
		if list.add_suggestion(suggestions[id]):
			_add_suggestion_to_tree(suggestions[id])
	# -----------------------
	
	# --- Add Group Suggestions ---
	var suggested_groups: Array = SingletonManager.TagIt.get_suggested_groups(tag_id)
	var groups_per_tag: Dictionary = SingletonManager.TagIt.get_groups_and_tags(suggested_groups)
	
	for group_id in groups_per_tag:
		var group_dict: Dictionary = groups_per_tag[group_id]
		_add_group_entries_to_tree(
				group_id,
				group_dict["group_name"],
				group_dict["tags"])
	# -----------------------------


func _do_add_tag(tag: String, list: String) -> void:
	var target_list: TagList = shared_list if list.is_empty() else lists.get(list)
	if target_list == null:
		return
	
	var id: int = SingletonManager.TagIt.get_tag_id(tag)
	
	if target_list.add_tag(tag, id) and current_list == list:
		_add_tag_to_tree(id, tag)


func _undo_add_tag(tag: String, list: String) -> void:
	var target_list: TagList = shared_list if list.is_empty() else lists.get(list)
	if target_list == null:
		return
	
	if target_list.remove_tag_text(tag) and current_list == list:
		tags_tree.remove_tag_from_text(tag)


func _add_tag_to_tree(tag_id: int, tag_text: String) -> void:
	var tag_data: Dictionary = SingletonManager.TagIt.get_tag_data_columns(tag_id, ["category_id", "tooltip"])
	
	var data_category: int = tag_data.get("category_id", 0)
	var tooltip_data: Variant = tag_data.get("tooltip", "")
	var icon: Texture2D = null
	var color: Color = Color.WHITE
	if 0 < data_category:
		icon = SingletonManager.TagIt.get_icon_texture(data_category)
		color = SingletonManager.TagIt.get_category_icon_color(data_category)
	
	tags_tree.add_tag(
			tag_id,
			tag_text,
			"" if tooltip_data == null else tooltip_data,
			icon,
			data_category,
			color)
	if not current_list.is_empty() and shared_list.has_id(tag_id): # We're not at the base
		tags_tree.set_tag_id_text_color(tag_id, Color.DARK_GRAY)


func _add_suggestion_to_tree(suggestion: String) -> void:
	if _suggestion_blacklist.has(suggestion):
		return
	suggestion_tags.add_suggestion(suggestion)


func _add_group_entries_to_tree(id: int, group_name: String, tags: Dictionary) -> void:
	if _group_blacklist.has(id) or tags.is_empty():
		return
	
	var valid_suggestions: Dictionary[int, String] = {}
	for tag_id in tags:
		valid_suggestions[tag_id] = tags[tag_id]
	
	if not valid_suggestions.is_empty():
		groups_tree.add_suggestions(group_name, valid_suggestions, id)


func _linked_has_tag(list: String, tag: String) -> bool:
	if list.is_empty():
		return shared_list.has_text(tag)
	
	var outer_list: TagList = lists.get(list)
	if outer_list == null:
		return shared_list.has_text(tag)
	else:
		return shared_list.has_text(tag) and outer_list.has_text(tag)


func _on_groups_suggestions_activated(suggestions: Dictionary[int, Dictionary]) -> void:
	if suggestions.is_empty():
		return
	
	var tags_to_add: Dictionary[String, Variant] = {} # Tag
	var groups_to_remove: Dictionary[int, Array] = {}
	var sugg_tags: Dictionary[int, String] = {}
	
	for group in suggestions:
		var existing_tags: Dictionary[int, String] = {}
		var group_tags: Array[String] = []
		
		for tag in suggestions[group]["tags"]:
			group_tags.append(tag)
			
			if SingletonManager.TagIt.has_tag(tag):
				existing_tags[SingletonManager.TagIt.get_tag_id(tag)] = tag
			else:
				tags_to_add[tag] = null
		
		var aliases: Dictionary = SingletonManager.TagIt.get_aliases_consequent_names_from(Arrays.create_typed(TYPE_INT, existing_tags.keys()))
		for tag_id in existing_tags:
			var text: String = aliases.get(tag_id, existing_tags[tag_id])
			tags_to_add[text] = null
		
		groups_to_remove[group] = group_tags
		if not existing_tags.is_empty():
			sugg_tags.merge(existing_tags)
	
	var list: TagList = lists.get(current_list, shared_list)
	
	var unadded_tags: Array[String] = []
	for tag in tags_to_add:
		var tag_true: String = tag
		if SingletonManager.TagIt.has_tag(tag):
			tag_true = SingletonManager.TagIt.get_alias_name(tag)
		
		if list.has_text(tag_true):
			continue
		unadded_tags.append(tag_true)
	
	if not unadded_tags.is_empty():
		_undo.create_action("Add Group Tags")
		_undo.add_do_method(_do_add_group_tags.bind(current_list, unadded_tags.duplicate(), groups_to_remove))
		_undo.add_undo_method(_undo_add_group_tags.bind(current_list, unadded_tags.duplicate(), suggestions))
		_undo.commit_action()
		list_changed.emit()
	
	# --- Add Local Suggestions ---
	if sugg_tags.is_empty():
		return
	var ids: Array[int] = []
	ids.assign(sugg_tags.keys())
	
	var sugg_ids: Array = SingletonManager.TagIt.get_suggestions_for_tags(ids)
	var local_suggestions: Dictionary = SingletonManager.TagIt.get_tags_name(sugg_ids) # id:Name
	
	for id in local_suggestions:
		var text: String = local_suggestions[id]
		if list.has_text(text):
			continue
		_add_suggestion_to_tree(text)
	
	for added_item in tags_to_add:
		if suggestion_tags.has_suggestion(added_item):
			suggestion_tags.delete_tag(added_item)
	# -----------------------


func _do_add_group_tags(on_list: String, tags: Array[String], groups_to_remove: Dictionary[int, Array]) -> void:
	# --- Remove from Groups ---
	groups_tree.remove_data(groups_to_remove)
	# --------------------------
	if tags.is_empty():
		return
	
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var current: bool = on_list == current_list
	for tag in tags:
		var tag_id: int = SingletonManager.TagIt.get_tag_id(tag)
		
		if list.add_tag(tag, tag_id) and current:
			_add_tag_to_tree(tag_id, tag)


func _undo_add_group_tags(on_list: String, tags: Array[String], group_data: Dictionary[int, Dictionary]) -> void:
	groups_tree.add_data(group_data)
	
	if tags.is_empty():
		return
	
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var current: bool = current_list == on_list
	for tag in tags:
		if list.remove_tag_text(tag) and current:
			tags_tree.remove_tag_from_text(tag)


func _on_suggestions_activated(suggestions: Array[String]) -> void:
	var tags_to_add: Array[String] = []
	var list: TagList = lists.get(current_list, shared_list)
	
	for tag in suggestions:
		var text: String = tag
		if SingletonManager.TagIt.has_tag(tag):
			text = SingletonManager.TagIt.get_alias_name(tag)
		if list.has_text(text):
			continue
		tags_to_add.append(text)
	
	if tags_to_add.is_empty():
		return
	
	_undo.create_action("Add Suggestion Tags")
	_undo.add_do_method(_do_add_suggestion_tags.bind(current_list, tags_to_add.duplicate(), suggestions.duplicate()))
	_undo.add_undo_method(_undo_add_suggestion_tags.bind(current_list, tags_to_add.duplicate(), suggestions.duplicate()))
	_undo.commit_action()
	list_changed.emit()


func _do_add_suggestion_tags(on_list: String, tags: Array[String], suggestions: Array[String]) -> void:
	for suggestion in suggestions:
		suggestion_tags.delete_tag(suggestion)
	
	if tags.is_empty():
		return
	
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var on_current: bool = on_list == current_list
	for item in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(item)
		if list.add_tag(item, id) and on_current:
			_add_tag_to_tree(id, item)


func _undo_add_suggestion_tags(on_list: String, tags: Array[String], suggestions: Array[String]) -> void:
	for suggestion in suggestions:
		_add_suggestion_to_tree(suggestion)
	
	if tags.is_empty():
		return
	
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var on_current: bool = current_list == on_list
	for tag in tags:
		if list.remove_tag_text(tag) and on_current:
			tags_tree.remove_tag_from_text(tag)


func _on_suggestions_deleted(suggestions: Array[String]) -> void:
	if suggestions.is_empty():
		return
	
	var blacklisted: Array[String] = []
	for item in suggestions:
		if _suggestion_blacklist.has(item):
			continue
		blacklisted.append(item)
	
	_undo.create_action("Delete Suggestions")
	_undo.add_do_method(_do_delete_suggestions.bind(blacklisted, suggestions.duplicate()))
	_undo.add_undo_method(_undo_delete_suggestions.bind(blacklisted, suggestions.duplicate()))
	_undo.commit_action()
	list_changed.emit()


func _do_delete_suggestions(blacklist: Array[String], suggestions: Array[String]) -> void:
	if SingletonManager.TagIt.settings.blacklist_removed:
		for item in blacklist:
			_suggestion_blacklist[item] = null
	for item in suggestions:
		suggestion_tags.delete_tag(item)


func _undo_delete_suggestions(blacklist: Array[String], suggestions: Array[String]) -> void:
	for item in blacklist:
		_suggestion_blacklist.erase(item)
	for item in suggestions:
		_add_suggestion_to_tree(item)


func _on_groups_deleted(group_ids: Array[int]) -> void:
	if group_ids.is_empty():
		return
	
	var blacklist: Array[int] = []
	var group_data: Dictionary[int, Dictionary] = {}
	
	for item in group_ids:
		group_data[item] = groups_tree.get_group_data(item)
		
		if _group_blacklist.has(item): continue
		
		blacklist.append(item)
	
	_undo.create_action("Delete Group")
	_undo.add_do_method(_do_delete_groups.bind(group_ids.duplicate(), blacklist.duplicate()))
	_undo.add_undo_method(_undo_delete_groups.bind(group_data, blacklist.duplicate()))
	_undo.commit_action()
	list_changed.emit()


func _do_delete_groups(groups: Array[int], blacklist: Array[int]) -> void:
	for group in groups:
		groups_tree.remove_group(group)
	if SingletonManager.TagIt.settings.blacklist_removed:
		for item in blacklist:
			_group_blacklist[item] = null


func _undo_delete_groups(group_data: Dictionary[int, Dictionary], blacklist: Array[int]) -> void:
	for group_id in group_data:
		var data: Dictionary = group_data[group_id]
		groups_tree.add_suggestions(
			data["title"],
			data["tags"],
			group_id)
	
	for item in blacklist:
		_group_blacklist.erase(item)


func _on_groups_dropped_on_tags(groups: Dictionary[int, Dictionary]) -> void:
	if groups.is_empty():
		return
	
	var unique_tags: Dictionary[String, Variant] = {}
	
	for group_id in groups:
		for tag in groups[group_id]["tags"]:
			var text: String = tag
			if SingletonManager.TagIt.has_tag(text):
				text = SingletonManager.TagIt.get_alias_name(text)
			unique_tags[text] = null
	
	var tags: Array[String] = Arrays.create_typed(TYPE_STRING, unique_tags.keys())
	
	_undo.create_action("Add Group Tags")
	_undo.add_do_method(_do_add_dropped_groups.bind(current_list, tags.duplicate(), groups.duplicate(true)))
	_undo.add_undo_method(_undo_add_dropped_groups.bind(current_list, tags.duplicate(), groups.duplicate(true)))
	_undo.commit_action()
	list_changed.emit()
	
	# --- Add Suggestions ---
	var ids: Array[int] = []
	for item in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(item)
		if 0 < id:
			ids.append(id)
	
	var result_ids: Array = SingletonManager.TagIt.get_suggestions_for_tags(ids)
	var suggestions: Dictionary = SingletonManager.TagIt.get_tags_name(result_ids) # id:Name
	var list: TagList = lists.get(current_list, shared_list)
	var is_base: bool = current_list.is_empty()
	
	for id in suggestions:
		var tag: String = suggestions[id]
		if list.has_text(tag):
			continue
		elif not is_base and shared_list.has_text(tag):
			continue
		
		suggestion_tags.add_suggestion(tag)
	
	for added_item in tags:
		if suggestion_tags.has_suggestion(added_item):
			suggestion_tags.delete_tag(added_item)


func _do_add_dropped_groups(on_list: String, tags: Array[String], groups: Dictionary[int, Dictionary]) -> void:
	for group_id in groups:
		groups_tree.remove_tags(group_id, groups[group_id]["tags"].keys())
	
	if tags.is_empty():
		return
	
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var u: bool = current_list == on_list
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		if list.add_tag(tag) and u:
			_add_tag_to_tree(id, tag)


func _undo_add_dropped_groups(on_list: String, tags: Array[String], groups: Dictionary[int, Dictionary]) -> void:
	groups_tree.add_data(groups)
	
	if tags.is_empty():
		return
	
	var list: TagList = shared_list if on_list.is_empty() else lists.get(on_list)
	if list == null:
		return
	
	var current: bool = on_list == current_list
	for tag in tags:
		if list.remove_tag_text(tag) and current:
			tags_tree.remove_tag_from_text(tag)


func _on_move_tags_to_new_list_pressed(tags: Array[String]) -> void:
	var line_confirm: ConfirmationDialog = load("res://scenes/dialogs/line_confirmation_dialog.gd").new()
	
	line_confirm.allow_empty = false
	line_confirm.title = "Alt List ID"
	for list in lists:
		if list.is_empty():
			continue
		line_confirm.text_blacklist.append(list)
	line_confirm.use_blacklist = true
	line_confirm.error_line_blacklist_word_msg = "List ID is already taken"
	line_confirm.exclusive = true
	add_child(line_confirm)
	line_confirm.popup_centered()
	line_confirm.grab_text_focus()
	var result: Array = await line_confirm.dialog_finished
	line_confirm.queue_free()
	
	if not result[0]:
		return
	
	_undo.create_action("Move Tags to New List")
	_undo.add_do_method(_do_move_tags_to_new_list.bind(current_list, result[1], tags.duplicate()))
	_undo.add_undo_method(_undo_move_tags_to_new_list.bind(current_list, result[1], tags.duplicate()))
	_undo.commit_action()
	list_changed.emit()


func _do_move_tags_to_new_list(from_list: String, to_list: String, tags: Array[String]) -> void:
	create_tag_list(to_list)
	
	var origin_list: TagList = shared_list if from_list.is_empty() else lists.get(from_list)
	var target_list: TagList = shared_list if to_list.is_empty() else lists.get(to_list)
	if origin_list == null or target_list == null:
		return
	
	var on_origin: bool = current_list == from_list
	var on_target: bool = current_list == to_list
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		var moved: bool = target_list.add_tag(tag, id)
		if moved and on_target:
			_add_tag_to_tree(id, tag)
		var removed: bool = origin_list.remove_tag_text(tag)
		if removed and on_origin:
			tags_tree.remove_tag_from_text(tag)


func _undo_move_tags_to_new_list(origin_list: String, target_list: String, tags: Array[String]) -> void:
	erase_tag_list(target_list)
	var origin: TagList = shared_list if origin_list.is_empty() else lists.get(origin_list)
	if origin == null:
		return
	
	var on_list: bool = origin_list == current_list
	for tag in tags:
		if origin.add_tag(tag) and on_list:
			var id: int = SingletonManager.TagIt.get_tag_id(tag)
			_add_tag_to_tree(id, tag)


func _on_move_tags_to_list_pressed(list: String, tags: Array[String]) -> void:
	if tags.is_empty() or (not list.is_empty() and not lists.has(list)):
		return
	
	_undo.create_action("Move Tags to List")
	_undo.add_do_method(_do_move_tags_to.bind(current_list, list, tags.duplicate()))
	_undo.add_undo_method(_do_move_tags_to.bind(list, current_list, tags.duplicate()))
	_undo.commit_action()
	list_changed.emit()


func _do_move_tags_to(origin: String, target: String, tags: Array[String]) -> void:
	var origin_list: TagList = shared_list if origin.is_empty() else lists.get(origin)
	var target_list: TagList = shared_list if target.is_empty() else lists.get(target)
	
	if origin_list == null or target_list == null or origin_list == target_list:
		return
	
	var on_origin: bool = current_list == origin
	var on_target: bool = current_list == target
	for tag in tags:
		var id: int = SingletonManager.TagIt.get_tag_id(tag)
		if origin_list.remove_tag_text(tag) and on_origin:
			tags_tree.remove_tag_from_text(tag)
		if target_list.add_tag(tag, id) and on_target:
			_add_tag_to_tree(id, tag)


func _on_open_prioritizer_pressed() -> void:
	if prioritizer_node == null:
		prioritizer_node = preload("res://scenes/tag_prioritizer.tscn").instantiate()
		add_child(prioritizer_node)
	if not prioritizer_node.visible:
		prioritizer_node.visible = true
	prioritizer_node.priority_tags = custom_order_list


func _on_prioritizer_close_pressed() -> void:
	prioritizer_node.visible = false


func _on_export_tags_pressed() -> void:
	var file_selector: FileDialog = preload("uid://bllqgi0evgkgk").new()
	file_selector.add_filter_extension("Text Files", "txt")
	file_selector.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_selector.access = FileDialog.ACCESS_FILESYSTEM
	file_selector.use_native_dialog = true
	file_selector.exclusive = true
	add_child(file_selector)
	file_selector.popup_centered()
	mouse_block = true
	
	var result: Array = await file_selector.dialog_finished
	file_selector.queue_free()
	
	if not result[0]:
		return
	
	var file_path: String = result[1]
	if not file_path.get_extension() == "txt":
		file_path += ".txt"
	
	var tags_file := FileAccess.open(file_path, FileAccess.WRITE)
	if tags_file != null:
		tags_file.store_string(tags_label.text)
		tags_file.close()


func _on_prioritizer_updated() -> void:
	list_changed.emit()


func _on_esix_api_suggestions_found(for_tag: String, for_list: String, suggestions: Array[String]) -> void:
	if for_tag.is_empty() or suggestions.is_empty() or (not lists.is_empty() and not lists.has(suggestions)):
		return
	
	var list: TagList = shared_list if for_list.is_empty() else lists.get(for_list)
	if list == null:
		return
	
	var on_same: bool = current_list == for_list
	for suggestion in suggestions:
		if list.add_suggestion(suggestion) and on_same:
			_add_suggestion_to_tree(suggestion)


func _on_copy_tags_btn_pressed() -> void:
	copy_generated_tags()


class TagList extends RefCounted:
	var _tag_ids: Dictionary[int, String] = {}
	var _tags: Dictionary[String, TagItem] = {}
	var _suggestions: Dictionary[String, Variant] = {}
	var origin_path: String = ""
	var image: Resource = null
	var image_type: String = ""
	var image_path: String = ""
	
	
	func tag_count() -> int:
		return _tags.size()
	
	
	func get_tag_ids() -> Array[int]:
		var ids: Array[int] = []
		if not _tag_ids.is_empty():
			ids.assign(_tag_ids.keys())
		return ids
	
	
	func add_tag(tag_name: String, tag_id: int = 0) -> bool:
		if _tags.has(tag_name) or (0 < tag_id and _tag_ids.has(tag_id)):
			return false
		
		var item: TagItem = TagItem.new_tag(tag_id, tag_name)
		_tags[tag_name] = item
		var id: int = item.tag_id
		if 0 < id:
			_tag_ids[id] = tag_name
		return true
	
	
	func add_suggestion(suggestion: String) -> bool:
		if _suggestions.has(suggestion):
			return false
		_suggestions[suggestion] = null
		return true
	
	
	func remove_suggestion(suggestion: String) -> bool:
		return _suggestions.erase(suggestion)
	
	
	func get_tag_text(tag_id: int) -> String:
		if not _tag_ids.has(tag_id):
			return ""
		var item: TagItem = _tags.get(_tag_ids[tag_id])
		if item == null:
			return ""
		return item.tag_text
	
	
	func remove_tag_text(tag: String) -> bool:
		if _tags.has(tag):
			var item: TagItem = _tags[tag]
			var id: int = item.tag_id
			_tags.erase(tag)
			_tag_ids.erase(id)
			return true
		return false
	
	
	func has_text(tag_text: String) -> bool:
		return _tags.has(tag_text)
	
	
	func has_id(tag_id: int) -> bool:
		return _tag_ids.has(tag_id)
	
	
	func get_list_tags() -> Dictionary[String, int]:
		var all_tags: Dictionary[String, int] = {}
		for tag in _tags:
			all_tags[tag] = _tags[tag].tag_id
		return all_tags
	
	
	func get_list_suggestions() -> Array[String]:
		return Arrays.create_typed(TYPE_STRING, _suggestions.keys())
	
	
	func clear() -> void:
		_tag_ids.clear()
		_tags.clear()
