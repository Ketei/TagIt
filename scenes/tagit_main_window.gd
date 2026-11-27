extends Control


# ----- Scene Preload -----
const CREATE_GROUP_DIALOG = preload("res://scenes/dialogs/create_group_dialog.tscn")
const NEW_TAG_DIALOG = preload("res://scenes/dialogs/new_tag_dialog.tscn")
const ICON_SELECTION_DIALOG = preload("res://scenes/dialogs/icon_selection_dialog.tscn")
const SITE_CONFIRMATION_DIALOG = preload("res://scenes/dialogs/site_confirmation_dialog.tscn")
const SET_DESC_DIALOG = preload("res://scenes/dialogs/set_desc_dialog.tscn")
const SET_DESC_CATEGORY_DIALOG = preload("res://scenes/dialogs/set_desc_category_dialog.tscn")
const COLOR_PICKER_DIALOG = preload("res://scenes/dialogs/color_picker_dialog.tscn")
const NEW_ALIAS_CONFIRM_DIALOG = preload("res://scenes/dialogs/new_alias_confirm_dialog.tscn")
const PROJECTS_CONTAINER = preload("res://scenes/projects_container.tscn")
const PROJECTS_CONTAINER_VERTICAL = preload("res://scenes/projects_container_vertical.tscn")
const SUGGENSTION_BLACKLIST = preload("res://scenes/suggenstion_blacklist.tscn")
const TEXT_LOADER = preload("res://scenes/text_loader.tscn")
const TAG_EXPORTER = preload("res://scenes/tag_exporter.tscn")
const ABOUT_WINDOW = preload("res://scenes/help_window.tscn")
# ----- Script Preload -----
const LineConfirmationDialog = preload("res://scenes/dialogs/line_confirmation_dialog.gd")
const UnsavedConfirmationDialog = preload("res://scenes/dialogs/unsaved_confirmation_dialog.gd")
# ----- Resource Preload -----
const EXPAND_DOWN_ICON = preload("res://icons/expand_down_icon.svg")
const EXPAND_UP_ICON = preload("res://icons/expand_up_icon.svg")
# ----- Hydrus -----
const LOCAL_ADDRESS: String = "http://127.0.0.1:%d/"
const HEADER: String = "Hydrus-Client-API-Access-Key:"
# ----- eSix -----
const ESIX_SEARCH_URL: String = "https://e621.net/wiki_pages/show_or_new?title="

# Endpoints
const THUMBNAILS: String = "get_files/thumbnail?file_id=%d"
const SEARCH: String = "get_files/search_files?tags="
const HYDRUS_FILE_ENDPOINT: String = "get_files/file?file_id=%d"

@export var search_time: float = 0.3

var _saving: bool = false # Used if a save instance is on screen.
var _save_required: bool = false
var _backup_required: bool = false

var _block_events: bool = false:
	set(is_blocking):
		_block_events = is_blocking
		set_process_input(!is_blocking)
var _help_pressed: bool = false
var _close_signaled: bool = false
var _cleanup_timeout: bool = false
var _sorting_displayed: bool = false
var _current_wiki_search: String = ""

var selector: Control = null:
	set(new_selector):
		selector = new_selector
		_block_events = selector != null
		menu_button.set_disable_shortcuts(selector != null)
		help_button.set_disable_shortcuts(selector != null)

var loaded_project: TagItProject

var icon_range: Array[int] = []

var current_project_uuid: String = "":
	set(t):
		return
	get():
		if loaded_project != null:
			return loaded_project._uuid
		return ""
var current_title: String = "":
	set(t):
		return
	get():
		if loaded_project != null:
			return loaded_project.title
		return ""

var hydrus_connected: bool = false:
	set(connection):
		hydrus_connected = connection
		if connection:
			settings_connection_status_txt_rect.texture = load("res://icons/connected_icon.svg")
			settings_connection_status_txt_rect.modulate = Color(0.441, 0.883, 0)
		else:
			settings_connection_status_txt_rect.texture = load("res://icons/disconnected_icon.svg")
			settings_connection_status_txt_rect.modulate = Color(0.78, 0.139, 0.117)
var loading_image: bool = false
var loading_thumbnails: bool = false:
	set(is_loading):
		loading_thumbnails = is_loading
		wiki_reload_images_button.disabled = is_loading
		thumbnail_size_changer.disabled = is_loading

var prio_list_node: Control = null
var sort_submenu: PopupMenu = null

var project_backup: AutoSave = null
var project_index: TagItProjectResource = null

# ----- Windows -----
@onready var tagger_container: PanelContainer = $MainContainer/TaggerContainer
@onready var wiki_panel: PanelContainer = $MainContainer/WikiPanel
@onready var tags_panel: PanelContainer = $MainContainer/TagsPanel
@onready var tools_panel: PanelContainer = $MainContainer/ToolsPanel
@onready var settings_panel: PanelContainer = $MainContainer/SettingsPanel
# -------------------

# --- Quick Access ---
@onready var template_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/TemplateBtn
# --------------------

# ----- Tagger -----
@onready var new_alt_list_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/NewAltListBtn
@onready var open_project_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/OpenBtn
@onready var save_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/SaveBtn
@onready var new_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/NewBtn
@onready var wizard_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/WizardBtn
@onready var menu_button: MenuButton = $MainContainer/MenuMargin/MenuContainer/MenuButtonCont/MenuButton
@onready var help_button: MenuButton = $MainContainer/MenuMargin/MenuContainer/MenuButtonCont/HelpButton
# ----------------

# ----- Tag Review -----
@onready var new_tag_btn: Button = $MainContainer/TagsPanel/TagsMargin/TagSearchContainer/MenuContainer/ButtonButtons/NewTagBtn
@onready var all_tags_tree: Tree = $MainContainer/TagsPanel/TagsMargin/TagSearchContainer/AllTagsTree
@onready var tag_editor: VBoxContainer = $MainContainer/TagsPanel/TagsMargin/TagEditContainer
@onready var tag_searcher: Control = $MainContainer/TagsPanel/TagsMargin/TagSearchContainer
@onready var save_tag_btn: Button = $MainContainer/TagsPanel/TagsMargin/TagEditContainer/MainContainer/WikiContainer/TitleContainer/SaveTagBtn
@onready var close_editor_btn: Button = $MainContainer/TagsPanel/TagsMargin/TagEditContainer/MainContainer/WikiContainer/TitleContainer/CloseEditorBtn
@onready var all_tags_search_ln_edt: LineEdit = $MainContainer/TagsPanel/TagsMargin/TagSearchContainer/MenuContainer/AllTagsSearchLnEdt
@onready var tag_search_container: Control = $MainContainer/TagsPanel/TagsMargin/TagSearchContainer
@onready var export_tag_btn: MenuButton = $MainContainer/TagsPanel/TagsMargin/TagSearchContainer/MenuContainer/ButtonButtons/ExportTagBtn

# ----------------
# ----- Settings -----
@onready var settings_new_icon_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/MainContainer/IconsContainer/TitleContainer/NewIconBtn
@onready var settings_new_group_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/MainContainer/GroupsContainer/TitleContainer/NewGroupBtn
@onready var settings_expand_api_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/EnableContainer/InfoContainer/ExpandBtn
@onready var settings_request_api_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/ApiContainer/ButtonsContainer/RequestAPIBtn
@onready var settings_connect_api_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/ApiContainer/ButtonsContainer/ConnectAPIBtn
@onready var settings_new_site_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/SitesAliasContainer/DataContainer/ButtonsContainer/NewSiteBtn
@onready var settings_new_cat_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/MainContainer/CategoryContainer/TitleContainer/NewCatBtn
@onready var settings_icons_tree: Tree = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/MainContainer/IconsContainer/IconsTree
@onready var settings_groups_tree: Tree = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/MainContainer/GroupsContainer/GroupsTree
@onready var settings_category_tree: Tree = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/MainContainer/CategoryContainer/CategoryTree
@onready var settings_sites_tree: Tree = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/CustomDataPanel/AllContainer/SitesAliasContainer/DataContainer/SitesTree
@onready var settings_api_container: HBoxContainer = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/ApiContainer
@onready var settings_image_load_spn_bx: SpinBox = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/EnableContainer/ToggleContainer/ImageLoadSpnBx
@onready var settings_load_img_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/EnableContainer/ToggleContainer/LoadImgChkBtn
@onready var settings_site_opt_btn: OptionButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/SitePanel/MainContainer/OptionsContainer/DefaultSiteOptBtn
@onready var settings_logs_txt_edt: TextEdit = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/LogsContainer/PanelContainer/MarginContainer/SettingsLogsTxtEdt
@onready var settings_key_ln_edt: LineEdit = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/ApiContainer/KeyContainer/KeyLnEdt
@onready var settings_port_spn_bx: SpinBox = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/ApiContainer/PortContainer/PortSpnBx
@onready var settings_connection_status_txt_rect: TextureRect = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ImagesPanel/MainContainer/ApiContainer/ButtonsContainer/ConnectionStatusTxtRect
@onready var settings_autofill_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/AutofillPanel/MainContainer/AutofillChkBtn
@onready var settings_include_invalid_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/InvalidPanel/MainContainer/IncludeInvalidChkBtn
@onready var settings_blacklist_remove_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/BlacklistPanel/MainContainer/BlacklistRemoveChkBtn
@onready var settings_link_e_six_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/LinksPanel/MainContainer/LinkESixChkBtn
@onready var settings_request_sugg_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ESixApiPanel/MainContainer/SuggestionsContainer/RequestSuggChkBtn
@onready var settings_relevancy_spn_bx: SpinBox = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ESixApiPanel/MainContainer/RelevancyContainer/MainContainer/RelevancySpnBx
@onready var settings_search_esix_tags_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ESixApiPanel/MainContainer/SearchContainer/SearchESixTagsBtn
@onready var settings_results_per_srch_spn_bx: SpinBox = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/ResultsPerSearchPanel/MainContainer/HBoxContainer/ResPerSrchSpnBx
@onready var settings_clear_logs_btn: Button = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/LogsContainer/LogsHeader/ClearLogsBtn
@onready var settings_blacklist_used_chk_btn: CheckButton = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/BlacklistUsedPanel/MainContainer/BlacklistUsedChkBtn
@onready var settings_backup_freq_spn_bx: SpinBox = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/AllScrlContainer/SettingsContainer/AutosavePanel/MainContainer/HBoxContainer/BackupFreqSpnBx

# --------------------
# ----- Wiki -----
@onready var hydrus_requester: HTTPRequest = $HydrusRequester
@onready var hydrus_large_image: HTTPRequest = $HydrusLargeImage
@onready var thumbnail_size_changer: OptionButton = $MainContainer/WikiPanel/WikiMargin/WikiContainer/ImageContainer/WikiDets/ThumbSize/ThumbnailSizeChanger
@onready var wiki_gallery: ScrollContainer = $MainContainer/WikiPanel/WikiMargin/WikiContainer/ImageContainer/ScrollContainer
@onready var wiki_title_lbl: Label = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/WikiTitleCtnr/TitleLbl
@onready var wiki_cat_lbl: Label = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/WikiTitleCtnr/CatContainer/WikiCatLbl
@onready var wiki_prio_lbl: Label = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/WikiTitleCtnr/CatContainer/WikiPrioLbl
@onready var wiki_rtl: RichTextLabel = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/WikiScrollCtnr/WikiRTL
@onready var wiki_search_ln_edt: LineEdit = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/SearchContainer/WikiSearchLnEdt
@onready var wiki_search_btn: Button = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/SearchContainer/SearchBtn
@onready var wiki_reload_images_button: Button = $MainContainer/WikiPanel/WikiMargin/WikiContainer/ImageContainer/WikiDets/ReloadImagesButton

@onready var wiki_section_separator: HSeparator = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/SectionSeparator
@onready var wiki_images_container: HFlowContainer = $MainContainer/WikiPanel/WikiMargin/WikiContainer/ImageContainer/ScrollContainer/ImagesContainer
@onready var wiki_aliases_container: VBoxContainer = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/AliasesContainer
@onready var wiki_aliases_label: Label = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/AliasesContainer/DataContainer/ScrollContainer/AliasesLabel
@onready var wiki_parents_container: VBoxContainer = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/ParentsContainer
@onready var wiki_parents_label: Label = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/InfoMargin/InfoContainer/ParentsContainer/DataContainer/ScrollContainer/ParentsLabel
@onready var wiki_image_side: VBoxContainer = $MainContainer/WikiPanel/WikiMargin/WikiContainer/ImageContainer
@onready var wiki_esix_search_btn: Button = $MainContainer/WikiPanel/WikiMargin/WikiContainer/WikiInfoContainer/SearchContainer/eSixSearchBtn

# ----------------
# ----- Backworkers -----
@onready var hydrus_images: HydrusWorker = $HydrusNode
@onready var backup_timer: Timer = $BackupTimer

# -----------------------

@onready var tab_bar: TabBar = $MainContainer/MenuMargin/MenuContainer/TabBar


func _ready() -> void:
	var window := get_window()
	window.title = "TagIt - New Project"
	window.min_size = Vector2i(1280, 720)
	hide_all_sections()
	tab_bar.current_tab = 0
	on_tab_changed(0)
	
	loaded_project = TagItProject.new()
	
	project_index = TagItProjectResource.get_projects()
	project_index.validate_projects()
	
	sort_submenu = PopupMenu.new()
	sort_submenu.add_item("Alphabetically", 0)
	sort_submenu.add_item("Category", 1)
	sort_submenu.add_item("Custom", 2)
	sort_submenu.add_separator("", 100)
	sort_submenu.add_item("- Configure Custom Sort -", 3)
	sort_submenu.id_pressed.connect(_on_sort_submenu_id_selected)
	menu_button.get_popup().set_item_submenu_node(7, sort_submenu)
	
	tag_searcher.visible = true
	tag_editor.visible = false
	settings_api_container.visible = false
	
	wiki_section_separator.visible = false
	wiki_parents_container.visible = false
	wiki_aliases_container.visible = false
	
	generate_icon_range()
	
	settings_category_tree.icon_range = icon_range.size() - 1
	settings_category_tree.icon_string = generate_icon_string()
	
	var categories: Dictionary = SingletonManager.TagIt.get_categories()
	var sites: Dictionary = SingletonManager.TagIt.get_sites()
	var groups: Dictionary = SingletonManager.TagIt.get_tag_groups()
	
	for category in categories:
		settings_category_tree.create_category(
				categories[category]["name"],
				categories[category]["description"],
				category,
				Arrays.binary_search(icon_range, categories[category]["icon_id"]),
				SingletonManager.TagIt.get_icon_texture(categories[category]["icon_id"]),
				Color.from_string(categories[category]["icon_color"], Color.WHITE))
	
	for icon in SingletonManager.TagIt.icons:
		var icon_name: String = SingletonManager.TagIt.get_icon_name(icon)
		var icon_texture: Texture2D = SingletonManager.TagIt.get_icon_texture(icon)
		settings_icons_tree.add_icon(icon, icon_name, icon_texture)
	
	for site in sites:
		settings_sites_tree.add_site(
			sites[site]["name"], site)
	
	for group in groups:
		settings_groups_tree.create_group(groups[group]["name"],
		group)
	
	var menu_popup: PopupMenu = menu_button.get_popup()
	
	menu_popup.set_item_shortcut(0, load("res://shortcuts/new_list_shortcut.tres"))
	menu_popup.set_item_shortcut(1, load("res://shortcuts/new_alt_list_shortcut.tres"))
	menu_popup.set_item_shortcut(2, load("res://shortcuts/save_list_shortcut.tres"))
	menu_popup.set_item_shortcut(3, load("res://shortcuts/save_list_as_shortcut.tres"))
	menu_popup.set_item_shortcut(4, load("res://shortcuts/open_list_shortcut.tres"))
	menu_popup.set_item_shortcut(10, load("res://shortcuts/add_template.tres"))
	menu_popup.set_item_shortcut(11, load("res://shortcuts/import_from_text_shortcut.tres"))
	menu_popup.set_item_shortcut(14, load("res://shortcuts/quit_shortcut.tres"))
	
	help_button.get_popup().set_item_shortcut(0, load("res://shortcuts/about_shortcut.tres"))
	
	# --- Loading and applying TagIt saved settings ---
	wiki_search_ln_edt.use_timer = SingletonManager.TagIt.settings.use_autofill
	settings_results_per_srch_spn_bx.value = SingletonManager.TagIt.settings.results_per_search
	settings_autofill_chk_btn.button_pressed = SingletonManager.TagIt.settings.use_autofill
	settings_include_invalid_chk_btn.button_pressed = SingletonManager.TagIt.settings.include_invalid
	settings_blacklist_remove_chk_btn.button_pressed = SingletonManager.TagIt.settings.blacklist_removed
	settings_link_e_six_chk_btn.button_pressed = SingletonManager.TagIt.settings.link_to_esix
	settings_load_img_chk_btn.button_pressed = SingletonManager.TagIt.settings.load_wiki_images
	settings_search_esix_tags_btn.button_pressed = SingletonManager.TagIt.settings.search_tags_on_esix
	if settings_load_img_chk_btn.button_pressed:
		settings_image_load_spn_bx.editable = true
		settings_key_ln_edt.editable = true
		settings_port_spn_bx.editable = true
		settings_request_api_btn.disabled = false
		settings_connect_api_btn.disabled = false
	settings_image_load_spn_bx.value = SingletonManager.TagIt.settings.wiki_images
	settings_request_sugg_chk_btn.button_pressed = SingletonManager.TagIt.settings.request_suggestions
	settings_relevancy_spn_bx.value = SingletonManager.TagIt.settings.suggestion_relevancy
	settings_relevancy_spn_bx.editable = settings_request_sugg_chk_btn.button_pressed
	settings_blacklist_used_chk_btn.button_pressed = SingletonManager.TagIt.settings.blacklist_used_suggestions
	wiki_image_side.visible = settings_load_img_chk_btn.button_pressed
	thumbnail_size_changer.select(SingletonManager.TagIt.settings.wiki_thumbnail_size)
	match SingletonManager.TagIt.settings.wiki_thumbnail_size:
		0:
			wiki_gallery.set_thumbnail_size(Vector2i(100, 100))
		1:
			wiki_gallery.set_thumbnail_size(Vector2i(150, 150))
		2:
			wiki_gallery.set_thumbnail_size(Vector2i(300, 300))
		3:
			wiki_gallery.set_thumbnail_size(Vector2i(600, 600))
	$MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer.size.x = SingletonManager.TagIt.settings.tag_container_width
	#tagger_suggestion_tree.size.y = SingletonManager.TagIt.settings.suggestions_height
	backup_timer.wait_time = maxf(60.0, float(SingletonManager.TagIt.settings.backup_frequency) * 60.0)
	settings_backup_freq_spn_bx.value = SingletonManager.TagIt.settings.backup_frequency
	
	# Checking for autosaves
	project_backup = AutoSave.get_autosave_file()
	if not project_backup.exited_correctly:
		#var restore_groups:Dictionary = SingletonManager.TagIt.get_groups_and_tags(project_backup.groups)
		tagger_container.set_tags_of_list("", project_backup.main_list)
		for list_id in project_backup.lists:
			tagger_container.set_tags_of_list(
					list_id,
					project_backup.lists[list_id],
					true)
		
		if not project_backup.project_uuid.is_empty():
			if project_index.project_exists(project_backup.project_uuid):
				var project: TagItProject = project_index.get_project_data(project_backup.project_uuid)
				if project != null:
					loaded_project._uuid = project_backup.project_uuid
					get_window().title = "TagIt - " + project.title
					
					tagger_container.restore_from_project(project)
					loaded_project = project
		set_save_required(true)
	
	# --- Window ---
	get_viewport().files_dropped.connect(_on_files_dropped)
	# --- Tagger ---
	template_btn.pressed.connect(on_menu_button_id_selected.bind(9))
	new_alt_list_btn.pressed.connect(on_menu_button_id_selected.bind(14))
	tab_bar.tab_changed.connect(on_tab_changed)
	open_project_btn.pressed.connect(on_menu_button_id_selected.bind(2))
	save_btn.pressed.connect(on_menu_button_id_selected.bind(1))
	new_btn.pressed.connect(on_menu_button_id_selected.bind(0))
	wizard_btn.pressed.connect(on_menu_button_id_selected.bind(8))
	menu_button.get_popup().id_pressed.connect(on_menu_button_id_selected)
	help_button.get_popup().id_pressed.connect(on_help_id_pressed)
	tagger_container.list_changed.connect(_list_changed)
	tagger_container.search_in_wiki_pressed.connect(_on_search_in_wiki_pressed)
	# --- Edit Tag ---
	all_tags_search_ln_edt.text_submitted.connect(on_search_text_submitted)
	new_tag_btn.pressed.connect(on_new_tag_pressed)
	close_editor_btn.pressed.connect(close_tag_editor)
	all_tags_tree.edit_tag_pressed.connect(on_edit_tag_pressed)
	all_tags_tree.export_tag_pressed.connect(on_export_tag_pressed)
	all_tags_tree.delete_tag_pressed.connect(on_delete_tag_pressed)
	export_tag_btn.get_popup().id_pressed.connect(on_export_button_id_pressed)
	$MainContainer/TagsPanel/TagsMargin/TagSearchContainer/MenuContainer/ButtonButtons/ImportMenuBtn.get_popup().id_pressed.connect(on_import_button_id_pressed)
	# --- Wiki ---
	thumbnail_size_changer.item_selected.connect(on_thumbnail_size_changed)
	wiki_search_ln_edt.text_submitted.connect(on_wiki_searched)
	hydrus_images.frames_created.connect(on_wiki_frame_created)
	hydrus_images.frames_loading_finished.connect(on_frames_loading_finished)
	wiki_gallery.thumbnail_pressed.connect(on_wiki_thumbnail_pressed)
	hydrus_images.full_image_loaded.connect(on_wiki_image_loaded)
	wiki_panel.load_next_image.connect(on_wiki_next_image)
	wiki_panel.load_previous_image.connect(on_wiki_previous_image)
	wiki_esix_search_btn.pressed.connect(on_esix_wiki_search)
	wiki_search_ln_edt.timer_finished.connect(on_wiki_timer_timeout)
	wiki_search_btn.pressed.connect(on_wiki_search_button_pressed)
	wiki_reload_images_button.pressed.connect(_on_reload_images_pressed)
	# --- Tools ---
	tools_panel.tags_requested.connect(_on_tool_tag_requested)
	# --- Settings ---
	settings_load_img_chk_btn.toggled.connect(on_api_toggle_changed)
	settings_expand_api_btn.pressed.connect(on_expand_api_pressed)
	settings_new_site_btn.pressed.connect(on_new_site_pressed)
	settings_category_tree.set_category_desc_pressed.connect(on_set_category_desc)
	settings_category_tree.set_category_color_pressed.connect(on_set_category_color)
	settings_category_tree.category_icon_changed.connect(on_category_icon_changed)
	settings_category_tree.category_deleted.connect(on_category_deleted)
	settings_new_cat_btn.pressed.connect(on_create_category_pressed)
	settings_groups_tree.group_desc_updated.connect(on_set_group_desc)
	settings_groups_tree.group_deleted.connect(on_group_deleted)
	settings_new_group_btn.pressed.connect(on_create_group_pressed)
	settings_icons_tree.icon_deleted.connect(on_delete_icon)
	settings_new_icon_btn.pressed.connect(on_create_icon_pressed)
	settings_connect_api_btn.pressed.connect(on_connect_to_hydrus)
	settings_request_api_btn.pressed.connect(on_request_pressed)
	settings_request_sugg_chk_btn.toggled.connect(_on_request_tags_toggled)
	settings_autofill_chk_btn.toggled.connect(on_autofill_toggled)
	settings_include_invalid_chk_btn.toggled.connect(on_include_invalid_toggled)
	settings_blacklist_remove_chk_btn.toggled.connect(on_blacklist_suggestions_toggled)
	settings_link_e_six_chk_btn.toggled.connect(on_link_esix_toggled)
	settings_request_sugg_chk_btn.toggled.connect(on_request_suggestions_toggled)
	settings_relevancy_spn_bx.value_changed.connect(on_suggest_relevancy_value_changed)
	settings_site_opt_btn.item_selected.connect(on_default_site_changed)
	settings_search_esix_tags_btn.toggled.connect(on_search_esix_tags_toggled)
	settings_results_per_srch_spn_bx.value_changed.connect(on_results_per_search_changed)
	settings_image_load_spn_bx.value_changed.connect(on_wiki_image_amount_changed)
	settings_clear_logs_btn.pressed.connect(_on_clear_logs_pressed)
	settings_blacklist_used_chk_btn.toggled.connect(_on_blacklist_used_suggestions_toggled)
	settings_backup_freq_spn_bx.value_changed.connect(_on_backup_timer_changed)
	# -- Others --
	backup_timer.timeout.connect(_on_backup_timer_timeout)
	
	SingletonManager.TagIt.website_created.connect(on_website_changed)
	SingletonManager.TagIt.website_deleted.connect(on_website_changed)
	SingletonManager.TagIt.tag_updated.connect(on_tag_updated)
	SingletonManager.TagIt.message_logged.connect(on_log_created)
	
	project_backup.exited_correctly = false # Set just in case.
	
	settings_sites_tree.website_activated.connect(_on_website_activated)
	
	if OS.has_feature("editor"): # Show splash only in editor for testing purposes.
		SingletonManager.TagIt.show_splash()
	
	var splash_time: float = maxf(0.0, 2.0 - SingletonManager.TagIt.get_splash_time())
	
	if 0.1 < splash_time:
		await get_tree().create_timer(splash_time).timeout
	
	SingletonManager.TagIt.hide_splash()
	
	if SingletonManager.TagIt.settings.news_shown < DataManager.TAGIT_VERSION_ARRAY:
		_block_events = true
		var news_window: PanelContainer = preload("res://scenes/update_window.tscn").instantiate()
		news_window.window_closed.connect(_on_news_closed)
		add_child(news_window)
		news_window.visible = true
	
	if SingletonManager.TagIt.settings.load_wiki_images and SingletonManager.TagIt.settings.has_valid_hydrus_login():
		settings_connection_status_txt_rect.modulate = Color(0.88, 0.727, 0.104)
		settings_connect_api_btn.disabled = true
		settings_request_api_btn.disabled = true
		settings_key_ln_edt.editable = false
		settings_port_spn_bx.editable = false
		
		settings_port_spn_bx.value = SingletonManager.TagIt.settings.hydrus_port
		settings_key_ln_edt.text = SingletonManager.TagIt.settings.hydrus_key
		hydrus_connected = await connect_to_hydrus(
				SingletonManager.TagIt.settings.hydrus_port,
				SingletonManager.TagIt.settings.hydrus_key)
		
		if not hydrus_connected:
			settings_request_api_btn.disabled = false
			settings_key_ln_edt.editable = true
			settings_port_spn_bx.editable = true
		else:
			settings_connect_api_btn.text = "Disconnect"
		
		settings_connect_api_btn.disabled = false


func _input(event: InputEvent) -> void:
	var _local_consumed: bool = false
	
	if event is InputEventKey: # General Input
		if event.echo or not event.pressed:
			return
		
		if event.ctrl_pressed and not event.alt_pressed:
			if event.keycode == KEY_TAB:
				if not tab_bar.has_focus():
					tab_bar.grab_focus()
				if Input.is_key_pressed(KEY_SHIFT):
					tab_bar.current_tab = posmod(tab_bar.current_tab - 1, 5)
				else:
					tab_bar.current_tab = posmod(tab_bar.current_tab + 1, 5)
				_local_consumed = true
			
		elif event.alt_pressed and not event.ctrl_pressed:
			if event.keycode == KEY_M:
				menu_button.get_popup().grab_focus()
				menu_button.show_popup()
				menu_button.get_popup().set_focused_item(0)
				_local_consumed = true
			elif event.keycode == KEY_H:
				help_button.get_popup().grab_focus()
				help_button.show_popup()
				help_button.get_popup().set_focused_item(0)
				_local_consumed = true
		
	if _local_consumed:
		get_viewport().set_input_as_handled()
		return


func _on_files_dropped(files: PackedStringArray) -> void:
	if 1 < files.size() or tab_bar.current_tab != 0:
		return
	
	tagger_container.set_image_from_path(files[0])


func _on_tool_tag_requested() -> void:
	var tags: Array[String] = []
	var tags_dict: Dictionary[String, int] = {}
	
	tags_dict.merge(tagger_container.shared_list.get_list_tags())
	
	for list_id in tagger_container.lists:
		tags_dict.merge(tagger_container.lists[list_id].get_list_tags())
	
	tags.assign(tags_dict.keys())
	tools_panel.submit_tags(tags)


func save_current_project() -> void:
	var texture: Texture2D = tagger_container.get_project_thumbnail_image()
	
	if texture != null:
		loaded_project.set_project_thumbnail(texture.get_image())
	else:
		loaded_project.set_project_thumbnail(null)
	
	var shared: ProjectList = loaded_project.shared_list

	shared.clear_tags()
	var shared_tags: Dictionary = tagger_container.shared_list.get_list_tags()
	for tag in shared_tags:
		shared.add_tag_to_list(tag)
	
	for suggestion in tagger_container.shared_list.get_list_suggestions():
		shared.add_tag_to_suggestions(suggestion)
	
	var group_data: Dictionary = tagger_container.get_groups_data()
	for group_id in group_data:
		var data: Dictionary = group_data[group_id]
		shared.add_group_suggestions(
				group_id,
				data["title"],
				data["tags"])
	
	var old_file: String = tagger_container.shared_list.origin_path
	var new_path: String = tagger_container.shared_list.image_path
	if new_path != old_file:
		var type: String = tagger_container.shared_list.image_type
		
		if FileAccess.file_exists(old_file):
			OS.move_to_trash(old_file)
		
		if type == "gif":
			shared.append_animation(new_path)
		elif type == "img":
			var t: ImageTexture = tagger_container.shared_list.image
			shared.save_list_image(t.get_image())
			
		elif type.is_empty():
			shared.save_list_image(null)
	
	for list_id in tagger_container.lists:
		var source: RefCounted = tagger_container.lists[list_id]
		var target: ProjectList = null
		if loaded_project.lists.has(list_id):
			target = loaded_project.get_list(list_id)
			target.clear_tags()
		else:
			target = loaded_project.new_list(list_id)
		
		var tags: Dictionary = source.get_list_tags()
		for tag in tags:
			target.add_tag_to_list(tag)
		
		for s in source.get_list_suggestions():
			target.add_tag_to_suggestions(s)
		
		if source.origin_path != source.image_path:
			var type: String = source.image_type
			if type.is_empty():
				target.save_list_image(null)
			elif type == "img":
				var tex: ImageTexture = source.image
				target.save_list_image(tex.get_image())
			elif type == "gif":
				target.append_animation(source.image_path)
	
	for existing_list in loaded_project.lists:
		if not tagger_container.lists.has(existing_list):
			loaded_project.erase_list(existing_list)
	
	loaded_project.save()
	if project_index.set_project_last_update(
			current_project_uuid,
			int(Time.get_unix_time_from_system())):
		project_index.save()
	set_save_required(false)


func _on_backup_timer_changed(new_value: int) -> void:
	new_value = clampi(new_value, 0, 30)
	if new_value <= 0:
		if not backup_timer.is_stopped():
			backup_timer.stop()
	else:
		backup_timer.wait_time = float(new_value) * 60.0
		if _save_required:
			if backup_timer.is_stopped():
				backup_timer.start()
			else:
				if float(new_value) * 60.0 < backup_timer.time_left:
					backup_timer.stop()
					backup_timer.start()
	
	SingletonManager.TagIt.settings.backup_frequency = new_value


func _on_backup_timer_timeout() -> void:
	if not _backup_required:
		return
	
	var main_tags: Array[String] = []
	main_tags.assign(
			tagger_container.shared_list.get_list_tags().keys())
	
	project_backup.main_list = main_tags
	
	project_backup.lists.clear()
	for list_id in tagger_container.lists:
		var tags: Array[String] = []
		tags.assign(
				tagger_container.lists[list_id].get_list_tags().keys())
		project_backup.lists[list_id] = tags
	
	project_backup.project_uuid = loaded_project._uuid
	
	project_backup.backup_data()


func _list_changed() -> void:
	if not _save_required:
		set_save_required(true)
	if not _backup_required:
		_backup_required = true
	if 0 < SingletonManager.TagIt.settings.backup_frequency and backup_timer.is_stopped():
		backup_timer.start()


func _on_blacklist_used_suggestions_toggled(enabled: bool) -> void:
	SingletonManager.TagIt.settings.blacklist_used_suggestions = enabled


func _on_sort_submenu_id_selected(id: int) -> void:
	match id:
		0:
			sort_tags_alphabetical()
		1:
			sort_tags_category()
		2: # Sort custom
			sort_tags_custom()
		3: # Setup sort custom
			show_custom_sorting_window()


func show_custom_sorting_window() -> void:
	tagger_container.show_custom_sorting_window()


func sort_tags_custom() -> void:
	tagger_container.sort_tags_custom()


func _on_news_closed() -> void:
	_block_events = false


func set_save_required(is_required: bool, suffix_change: bool = true) -> void:
	_save_required = is_required
	if suffix_change:
		var window := get_window()
		if is_required:
			if not window.title.ends_with("*"):
				window.title += "*"
		else:
			if window.title.ends_with("*"):
				window.title = window.title.trim_suffix("*")


func on_import_button_id_pressed(id: int) -> void:
	var new_file_dialog := FileDialog.new()
	new_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	new_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	new_file_dialog.add_filter("*.json", "JSON Files")
	new_file_dialog.use_native_dialog = true
	new_file_dialog.file_selected.connect(on_file_selected.bind(id == 1,  new_file_dialog))
	new_file_dialog.canceled.connect(on_export_dialog_cancelled.bind(new_file_dialog))
	add_child(new_file_dialog)
	new_file_dialog.show()


func on_export_button_id_pressed(id: int) -> void:
	match id:
		0: # Export tags
			on_export_tags_pressed()
		1: # Export All
			on_tags_exported(SingletonManager.TagIt.get_all_tag_ids(true))


func on_file_selected(file_path: String, overwrite: bool, file_dialog: FileDialog) -> void:
	var json := JSON.new()
	var file_string: String = FileAccess.get_file_as_string(file_path)
	
	file_dialog.queue_free()
	
	if file_string.is_empty():
		SingletonManager.TagIt.log_message(
				"The file couldn't be loaded.",
				DataManager.LogLevel.ERROR)
		notify_import(false, false)
		return
	
	if json.parse(file_string) != OK:
		SingletonManager.TagIt.log_message(
				str(
						"There was an error while trying to parse tag data on line ",
						json.get_error_line(),
						".\nError: ",
						json.get_error_message()),
				DataManager.LogLevel.ERROR)
		notify_import(false, false)
		return
	
	if typeof(json.data) != TYPE_DICTIONARY:
		SingletonManager.TagIt.log_message(
				"The data structure in the provided JSON couldn't be loaded.",
				DataManager.LogLevel.ERROR)
		notify_import(false, false)
		return
		
	var data: Dictionary = json.data.duplicate()

	if not json.data.has("type"):
		SingletonManager.TagIt.log_message(
				"[JSON PARSER] JSON missing type.",
				DataManager.LogLevel.ERROR)
		notify_import(false, false)
		return
	
	if data["type"] == 0:
		if not data.has_all(["aliases", "category", "group", "group_desc", "group_suggestions", "is_valid", "name", "parents", "priority", "suggestions", "tooltip", "type", "wiki"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] JSON data is a dictionary but is missing some keys.", SingletonManager.TagIt.LogLevel.ERROR)
			notify_import(false, false)
			return
	
		if not typeof(data["category"]) == TYPE_DICTIONARY or not data["category"].has_all(["category_color", "category_icon", "description", "icon_name", "name"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] JSON data category is missing some data.", SingletonManager.TagIt.LogLevel.ERROR)
			notify_import(false, false)
			return
		
		json_tag_to_db(data, overwrite)
		
	elif data["type"] == 1:
		if not data.has_all(["categories", "groups", "icons", "tags", "type"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] JSON data is a dictionary but is missing some keys.", SingletonManager.TagIt.LogLevel.ERROR)
			notify_import(false, false)
			return
		json_group_to_db(data, overwrite)


func on_export_tags_pressed() -> void:
	selector = TAG_EXPORTER.instantiate()
	selector.export_tags_pressed.connect(on_tags_exported)
	selector.export_tags_cancelled.connect(on_tags_export_cancelled)
	add_child(selector)


func on_tags_export_cancelled() -> void:
	selector.visible = false
	selector.queue_free()
	selector = null


func on_tags_exported(tag_ids: Array[int]) -> void:
	var new_file_dialog := FileDialog.new()
	new_file_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	new_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	new_file_dialog.add_filter("*.json", "JSON Files")
	new_file_dialog.use_native_dialog = true
	new_file_dialog.file_selected.connect(on_export_tags_path_selected.bind(tag_ids, new_file_dialog))
	new_file_dialog.canceled.connect(on_export_dialog_cancelled.bind(new_file_dialog))
	add_child(new_file_dialog)
	
	if selector != null:
		selector.visible = false
		selector.queue_free()
		selector = null
	
	new_file_dialog.show()


func on_export_tags_path_selected(path: String, tag_ids: Array[int], file_dialog: FileDialog) -> void:
	db_group_to_json(tag_ids, path)
	file_dialog.queue_free()


func on_export_dialog_cancelled(file_dialog: FileDialog) -> void:
	file_dialog.queue_free()


func on_wiki_image_amount_changed(new_amount: int) -> void:
	SingletonManager.TagIt.settings.wiki_images = new_amount


func on_results_per_search_changed(new_amount: int) -> void:
	SingletonManager.TagIt.settings.results_per_search = new_amount


func on_search_esix_tags_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.search_tags_on_esix = is_toggled


func on_wiki_timer_timeout() -> void:
	if not wiki_search_ln_edt.has_focus():
		return
	
	wiki_search_ln_edt.clear_list()
	
	var clean_text: String = wiki_search_ln_edt.text.strip_edges().to_lower()
	var prefix: bool = clean_text.ends_with(DataManager.SEARCH_WILDCARD)
	var suffix: bool = clean_text.begins_with(DataManager.SEARCH_WILDCARD)
	
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
		results = SingletonManager.TagIt.search_for_tag_contains(clean_text, wiki_search_ln_edt.item_limit, true)
	elif suffix:
		results = SingletonManager.TagIt.search_for_tag_suffix(clean_text, wiki_search_ln_edt.item_limit, true)
	else:
		results = SingletonManager.TagIt.search_for_tag_prefix(clean_text, wiki_search_ln_edt.item_limit, true)
	
	var id_results: Array[int] = Array(SingletonManager.TagIt.get_tags_ids(results).values(), TYPE_INT, &"", null)
	
	var tags_with_aliases: Dictionary = SingletonManager.TagIt.get_aliases_consequent_names_from(id_results)
	
	if not results.is_empty():
		for tag in results:
			if tags_with_aliases.has(SingletonManager.TagIt.get_tag_id(tag)):
				wiki_search_ln_edt.add_item(tag, tags_with_aliases[SingletonManager.TagIt.get_tag_id(tag)])
			else:
				wiki_search_ln_edt.add_item(tag)
		wiki_search_ln_edt.show_items()


func sort_tags_alphabetical() -> void:
	if _sorting_displayed:
		return
	tagger_container.sort_tags_alphabetical()


func sort_tags_category() -> void:
	if _sorting_displayed:
		return
	tagger_container.sort_tags_category()


func on_wizard_finished(tags: Array[String], inputs_silenced: Control, silenced: bool) -> void:
	tagger_container.add_tags_from_action("Add Wizard Tags", tags)
	_block_events = false
	selector.queue_free()
	selector = null
	
	if silenced and inputs_silenced != null:
		inputs_silenced.set_process_input(true)


func on_wizard_cancelled(inputs_silenced: Control, silenced: bool) -> void:
	selector.queue_free()
	selector = null
	if silenced and inputs_silenced != null:
		inputs_silenced.set_process_input(true)


func on_esix_wiki_search() -> void:
	OS.shell_open(
		ESIX_SEARCH_URL + wiki_search_ln_edt.text.strip_edges())


func _on_create_alt_list_pressed() -> void:
	if tagger_container.lists.is_empty() and 0 < tagger_container.shared_list.tag_count():
		if tab_bar.current_tab != 0:
			tab_bar.current_tab = 0
			on_tab_changed(0)
		new_alt_list_btn.disabled = true
		await tagger_container.launch_alt_wizard()
		new_alt_list_btn.disabled = false
	else:
		var line_confirm: = preload("res://scenes/dialogs/line_confirmation_dialog.gd").new()
		line_confirm.line_placeholder_text = "List ID"
		line_confirm.use_blacklist = true
		line_confirm.error_line_blacklist_word_msg = "ID already used"
		line_confirm.exclusive = true
		line_confirm.allow_empty = false
		
		for list_id in tagger_container.lists:
			line_confirm.text_blacklist.append(list_id)
		
		add_child(line_confirm)
		line_confirm.popup_centered()
		line_confirm.grab_text_focus()
		
		new_alt_list_btn.disabled = true
		var result: Array = await line_confirm.dialog_finished
		line_confirm.queue_free()
		new_alt_list_btn.disabled = false
		if not result[0]:
			return
		
		var id: String = result[1]
		if tagger_container.create_tag_list_with_undo(id):
			tagger_container.load_tag_list(id)


func instantiate_save_selector() -> void:
	var texture: Texture2D = tagger_container.get_project_thumbnail_image()
	backup_timer.paused = true
	_saving = true
	selector = PROJECTS_CONTAINER_VERTICAL.instantiate()
	selector.use_descriptions = false
	selector.editable_cards = true
	selector.use_search = false
	selector.use_save = true
	selector.dim_background = true
	selector.use_close = false
	selector.card_saved.connect(on_selector_project_saved)
	selector.close_pressed.connect(on_selector_close_pressed.bind(true))
	add_child(selector)
	selector.set_emit_signals(false)
	selector.add_project(
		current_title,
		"",
		texture,
		current_project_uuid,
		0)
	selector.play_intro()
	await selector.intro_finished
	selector.set_emit_signals(true)
	selector.focus_title()
	backup_timer.paused = false


func instance_project_loader_selector() -> void:
	backup_timer.paused = true
	selector = PROJECTS_CONTAINER.instantiate()
	selector.use_descriptions = false
	selector.dim_background = true
	selector.allow_card_signals = false
	add_child(selector)
	selector.focus_main()
	selector.set_emit_signals(false)
	selector.card_selected.connect(on_selector_project_selected)
	selector.close_pressed.connect(on_selector_close_pressed)
	selector.card_deleted.connect(on_selector_project_deleted)
	
	for project_uid in project_index.get_project_ids():
		var data: Dictionary = project_index.get_display_card_data(project_uid)
		selector.add_project(
			data.get("title", "[CARD TITLE ERR]"),
			"",
			data.get("thumbnail", null),
			project_uid)
	selector.play_intro()
	
	await selector.intro_finished
	
	selector.set_emit_signals(true)
	backup_timer.paused = false


func instantiate_text_loader() -> void:
	selector = TEXT_LOADER.instantiate()
	selector.tags_split.connect(on_split_tags)
	selector.split_cancelled.connect(on_split_cancelled)
	add_child(selector)
	selector.focus_main()


func on_split_cancelled() -> void:
	selector.visible = false
	selector.queue_free()
	selector = null


func on_split_tags(tags: PackedStringArray) -> void:
	tagger_container.add_tags_from_action("Add Tags from Text", tags)
	selector.visible = false
	selector.queue_free()
	selector = null


func instance_preset_selector() -> void:
	var templates := TemplateResource.get_templates()
	
	selector = PROJECTS_CONTAINER.instantiate()
	selector.dim_background = true
	add_child(selector)
	selector.focus_main()
	selector.set_emit_signals(false)
	selector.card_selected.connect(on_selector_template_selected)
	selector.close_pressed.connect(on_selector_close_pressed)
	selector.card_deleted.connect(on_selector_template_erased)
	
	for template_uid in templates.get_template_uuids():
		var template: TagItTemplate = templates.get_template(template_uid)
		var texture: ImageTexture = template.get_thumbnail()
		
		selector.add_project(
				template.title,
				template.description,
				texture,
				template_uid)
	
	selector.play_intro()
	await selector.intro_finished
	selector.set_emit_signals(true)


func instantiate_wizard() -> void:
	var input_silenced: Control = null
	if tagger_container.visible:
		input_silenced = tagger_container
	elif wiki_panel.visible:
		input_silenced = wiki_panel
	elif tools_panel.visible:
		input_silenced = tools_panel
	var processing_input: bool = input_silenced.is_processing_input() if input_silenced != null else false
	if input_silenced != null:
		input_silenced.set_process_input(false)
	
	var res: Resource = tagger_container.get_current_list_image()
	selector = preload("res://scenes/wizard.tscn").instantiate()
	selector.wizard_finished.connect(on_wizard_finished.bind(input_silenced, processing_input))
	selector.wizard_cancelled.connect(on_wizard_cancelled.bind(input_silenced, processing_input))
	add_child(selector)
	selector.focus_main()
	selector.set_project_texture(res)


func instantiate_blacklist() -> void:
	selector = SUGGENSTION_BLACKLIST.instantiate()
	selector.suggestion_blacklist = tagger_container._suggestion_blacklist
	selector.group_blacklist = tagger_container._group_blacklist
	selector.blacklist_submitted.connect(on_new_blacklist)
	selector.blacklist_cancelled.connect(on_blacklist_cancelled)
	add_child(selector)


func on_blacklist_cancelled() -> void:
	selector.visible = false
	selector.queue_free()
	selector = null


func on_new_blacklist() -> void:
	selector.visible = false
	selector.queue_free()
	selector = null
	_list_changed()


func on_menu_button_id_selected(id: int) -> void:
	match id:
		0: # New List
			if _block_events:
				return
			if _save_required:
				backup_timer.paused = true
				var save_confirmation := preload("res://scenes/dialogs/unsaved_confirmation_dialog.gd").new()
				add_child(save_confirmation)
				save_confirmation.show()
				var result: int = await save_confirmation.dialog_finished
				if result == 0: # Save selected. Show Saving and wait for dialog
					if not loaded_project._uuid.is_empty():
						save_current_project()
					else:
						if selector != null:
							SingletonManager.TagIt.log_message(
								"[ERROR] Loading tried to save but selector is in memory.",
								SingletonManager.TagIt.LogLevel.ERROR)
							save_confirmation.queue_free()
							backup_timer.paused = false
							return
						
						instantiate_save_selector()
						
						await selector.outro_finished
						
						if _save_required: # Save was cancelled
							save_confirmation.queue_free()
							backup_timer.paused = false
							return
				elif result == 2: # Cancel
					save_confirmation.queue_free()
					backup_timer.paused = false
					return
				save_confirmation.queue_free()
			new_list()
		1: # Save:
			if _block_events:
				return
			
			if loaded_project == null:
				loaded_project = TagItProject.new()
			
			if not loaded_project._uuid.is_empty():
				save_current_project()
			else:
				if selector != null:
					SingletonManager.TagIt.log_message(
						"[ERROR] Loading tried to save but selector is in memory.",
						SingletonManager.TagIt.LogLevel.ERROR)
					return
				
				instantiate_save_selector()
		2: # Load List
			if _block_events:
				return
			if selector != null:
				SingletonManager.TagIt.log_message(
					"[ERROR] Loading tried to open but selector is in memory.",
					SingletonManager.TagIt.LogLevel.ERROR)
				return
			instance_project_loader_selector()
		4: # Sort Alphabetical
			return
		7: # Suggestion Blacklist
			if _block_events:
				return
			instantiate_blacklist()
		8: # Wizard
			if _block_events:
				return
			instantiate_wizard()
		9: # Load Preset
			if _block_events:
				return
			instance_preset_selector()
		10: # From Text
			if _block_events:
				return
			instantiate_text_loader()
		11: # Quit
			get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		14: # New Alt List
			if _block_events:
				return
			_on_create_alt_list_pressed()
		16: # Save as
			if _block_events:
				return
			if selector != null:
				SingletonManager.TagIt.log_message(
					"[ERROR] Loading tried to save but selector is in memory.",
					SingletonManager.TagIt.LogLevel.ERROR)
				return
			
			instantiate_save_selector()
		17: # Change Prio
			if prio_list_node != null:
				return
			tagger_container._on_open_prioritizer_pressed()


func on_help_id_pressed(id: int) -> void:
	match id:
		0:
			if _help_pressed or _block_events:
				return
			
			get_tree().paused = true
			_help_pressed = true
			_block_events = true
			var new_help := ABOUT_WINDOW.instantiate()
			add_child(new_help)
			await new_help.close_pressed
			new_help.visible = false
			new_help.queue_free()
			_help_pressed = false
			_block_events = false
			get_tree().paused = false


func new_list() -> void:
	loaded_project = TagItProject.new()
	tagger_container.clear()
	set_save_required(false, false)
	_backup_required = false
	get_window().title = "TagIt - New Project"
	if not backup_timer.is_stopped():
		backup_timer.stop()


func on_selector_project_saved(title: String) -> void:
	selector.set_emit_signals(false)
	if SingletonManager.TagIt.verbose:
		SingletonManager.TagIt.log_silent(
				"[TagIt] Saving project with UUID: " + current_project_uuid,
				DataManager.LogLevel.INFO)
	
	loaded_project.title = title
	
	if current_project_uuid.is_empty():
		loaded_project._uuid = UUID.generate_new()
		project_index.create_from_project(loaded_project)
		project_index.save()
	
	save_current_project()
	
	set_save_required(false, false)
	get_window().title = "TagIt - " + title
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null
	_saving = false


func on_selector_project_selected(project_uuid: String) -> void:
	selector.set_emit_signals(false)
	if SingletonManager.TagIt.verbose:
		SingletonManager.TagIt.log_silent(
				"[TagIt] Opening project with UUID: " + project_uuid,
				DataManager.LogLevel.INFO)
	
	var project: TagItProject = project_index.get_project_data(project_uuid)
	tagger_container.load_project(project)
	loaded_project = project
	
	get_window().title = "TagIt - " + project.title
	set_save_required(false, false)
	current_title = project.title
	
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null


func on_selector_project_deleted(project_uuid: String) -> void:
	if SingletonManager.TagIt.verbose:
		SingletonManager.TagIt.log_silent(
				"[TagIt] Deleting project with UUID: " + project_uuid,
				DataManager.LogLevel.INFO)
	
	project_index.delete_project(project_uuid)
	project_index.save()
	
	if loaded_project._uuid == project_uuid:
		loaded_project._uuid = ""
		set_save_required(true)


func on_selector_close_pressed(is_save: bool = false) -> void:
	selector.set_emit_signals(false)
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null
	if is_save:
		_saving = false


func on_selector_template_selected(template_uuid: String) -> void:
	selector.set_emit_signals(false)
	var request_suggestions: bool = SingletonManager.TagIt.settings.request_suggestions
	SingletonManager.TagIt.settings.request_suggestions = false
	var templates := TemplateResource.get_templates()
	var template_data: = templates.get_template(template_uuid)
	
	tagger_container.load_template(template_data)
	
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null
	SingletonManager.TagIt.settings.request_suggestions = request_suggestions


func on_selector_template_erased(template_uuid: String) -> void:
	tools_panel.on_template_deleted(template_uuid)
	var templates := TemplateResource.get_templates()
	templates.erase_template(template_uuid)
	templates.save()


func on_default_site_changed(default_site: int) -> void:
	SingletonManager.TagIt.settings.default_site = default_site


func on_suggest_relevancy_value_changed(new_value: int) -> void:
	SingletonManager.TagIt.settings.suggestion_relevancy = new_value


func on_request_suggestions_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.request_suggestions = is_toggled


func on_autofill_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.use_autofill = is_toggled
	wiki_search_ln_edt.use_timer = is_toggled
	tagger_container.set_autofill(is_toggled)


func on_include_invalid_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.include_invalid = is_toggled


func on_blacklist_suggestions_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.blacklist_removed = is_toggled


func on_link_esix_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.link_to_esix = is_toggled


func parse_hydrus_image_headers(headers_array: PackedStringArray) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func get_thumbnails(ids_array: Array) -> void:
	if loading_thumbnails:
		return
	
	loading_thumbnails = true
	# http://127.0.0.1:%d/ -> http://127.0.0.1:1234/
	var ip_port: String = LOCAL_ADDRESS % SingletonManager.TagIt.settings.hydrus_port
	
	# http://127.0.0.1:1234/ -> http://127.0.0.1:1234/get_files/thumbnail?file_id=%d
	var thumbnail_endpoint: String = ip_port.path_join(THUMBNAILS)
	
	#var url_building: String = LOCAL_ADDRESS.format([SingletonManager.TagIt.settings.hydrus_port]) + THUMBNAILS
	var frames_to_create: Dictionary = {}
	var headers := get_hydrus_headers()
	
	for pic_id in ids_array:
		if _close_signaled:
			break
		var url: String = thumbnail_endpoint % pic_id
		
		hydrus_requester.request(url, headers)
		var response_array = await hydrus_requester.request_completed
		
		if response_array[0] != OK or response_array[1] != 200:
			continue
		
		var _heads: Dictionary = parse_hydrus_image_headers(response_array[2])
		frames_to_create[int(pic_id)] = {
			"data": response_array[3],
			"format": _heads["content-type"].split("/")[1]
			}
		
	if not _close_signaled:
		hydrus_images.create_frames.emit(frames_to_create)


func on_wiki_frame_created(frames: SpriteFrames, id: int) -> void:
	wiki_gallery.create_image(frames.get_frame_texture(&"default", 0), id)


func on_wiki_thumbnail_pressed(thumbnail_id: int, img_idx: int) -> void:
	if loading_image:
		return
	
	loading_image = true
	wiki_panel.show_spinner()
	var ip_port: String = LOCAL_ADDRESS % SingletonManager.TagIt.settings.hydrus_port
	var endpoint: String = ip_port.path_join(HYDRUS_FILE_ENDPOINT)
	var url: String = endpoint % thumbnail_id
	
	hydrus_large_image.request(url, get_hydrus_headers())
	var response: Array = await hydrus_large_image.request_completed
	
	if response[0] != OK or response[1] != 200 or _close_signaled:
		wiki_panel.hide_throbber()
		loading_image = false
		return
	
	var _heads: Dictionary = parse_hydrus_image_headers(response[2])
	hydrus_images.load_full_image.emit(response[3], _heads["content-type"].split("/")[1])
	wiki_panel.image_index = img_idx


func _on_search_in_wiki_pressed(tag: String) -> void:
	if wiki_search_ln_edt.editable:
		tab_bar.current_tab = 1
		wiki_search_ln_edt.text = tag
		on_wiki_searched(tag)


func on_wiki_image_loaded(full_image: SpriteFrames, animated: bool) -> void:
	if not animated:
		wiki_panel.set_static_image(
				full_image.get_frame_texture(&"default", 0))
	else:
		wiki_panel.set_gif(full_image)
	
	loading_image = false


func _on_reload_images_pressed() -> void:
	if not SingletonManager.TagIt.settings.load_wiki_images or not hydrus_connected:
		return
	wiki_search_ln_edt.editable = false
	wiki_search_btn.disabled = true
	
	wiki_gallery.clear_gallery()
	var files = await search_hydrus_files(
			Array([_current_wiki_search], TYPE_STRING, &"", null),
			SingletonManager.TagIt.settings.wiki_images)
	get_thumbnails(files)


func on_wiki_next_image(from: int) -> void:
	var new_index: int = posmod(from + 1, wiki_images_container.get_child_count())
	var image_id: int = wiki_images_container.get_child(new_index).get_meta(&"image_id", -1)
	if image_id != -1 and new_index != from:
		wiki_panel.show_spinner()
		on_wiki_thumbnail_pressed(image_id, new_index)


func on_wiki_previous_image(from: int) -> void:
	var new_index: int = posmod(from - 1, wiki_images_container.get_child_count())
	var image_id: int = wiki_images_container.get_child(new_index).get_meta(&"image_id", -1)
	if image_id != -1 and new_index != from:
		wiki_panel.show_spinner()
		on_wiki_thumbnail_pressed(image_id, new_index)


func get_hydrus_headers(key: String = SingletonManager.TagIt.settings.hydrus_key) -> PackedStringArray:
	return PackedStringArray([HEADER + key])


func search_hydrus_files(tags_array: Array[String], tag_count: int) -> Array[int]:
	if not hydrus_connected:
		return []
	
	var ip_address: String = LOCAL_ADDRESS % SingletonManager.TagIt.settings.hydrus_port
	var endpoint: String = ip_address.path_join(SEARCH)
	var url = endpoint
	
	#var request_url: String = LOCAL_ADDRESS.format([SingletonManager.TagIt.settings.hydrus_port]) + SEARCH
	
	if not tags_array.is_empty():
		var tags_to_format: String = "["
		#var tag_category := SingletonManager.TagIt.category
		for tag in tags_array:
			var prefix_text: String = SingletonManager.TagIt.get_hydrus_category_prefix(SingletonManager.TagIt.get_tag_data_column(SingletonManager.TagIt.get_tag_id(tag), "category_id")) if SingletonManager.TagIt.has_tag(tag) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(tag)) else ""
			if not prefix_text.is_empty():
				prefix_text += ":"
			tags_to_format += "\"" + prefix_text + tag  + "\","
		tags_to_format += "\"system:limit={0}\",".format([str(tag_count)])
		tags_to_format += "\"system:filetype=image,gif\","
		tags_to_format += "\"system:archive\""
		tags_to_format += "]"
		url += tags_to_format.uri_encode() + "&"
	url += "file_sort_type=4"
	hydrus_requester.request(url, get_hydrus_headers())
	
	var response = await hydrus_requester.request_completed
	
	if int(response[0]) != OK or int(response[1]) != 200:
		SingletonManager.TagIt.log_message(
			"API response was not 0, 200\nResponse: " + str(response[0]) + ", " + str(response[1]),
			SingletonManager.TagIt.LogLevel.WARNING
		)
		return[]
	
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var parsed = json.get_data()
	var ids: Array[int] = []
	ids.assign(parsed["file_ids"])
	
	return ids


func on_connect_to_hydrus() -> void:
	if not hydrus_connected:
		settings_request_api_btn.disabled = true
		settings_connect_api_btn.disabled = true
		settings_key_ln_edt.editable = false
		settings_port_spn_bx.editable = false
		settings_connection_status_txt_rect.modulate = Color(0.88, 0.727, 0.104)
		hydrus_connected = await connect_to_hydrus(int(settings_port_spn_bx.value), settings_key_ln_edt.text)
		
		if not hydrus_connected:
			settings_request_api_btn.disabled = false
		else:
			settings_connect_api_btn.text = "Disconnect"
		settings_connect_api_btn.disabled = false
	else:
		settings_connect_api_btn.text = "Connect"
		settings_request_api_btn.disabled = false
		settings_key_ln_edt.editable = true
		settings_port_spn_bx.editable = true
		hydrus_connected = false
		settings_connection_status_txt_rect.modulate = Color(0.78, 0.137, 0.118)


func parse_hydrus_headers(headers_array: Array) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func connect_to_hydrus(port: int, key: String) -> bool:
	var ip_address: String = LOCAL_ADDRESS % port
	var url: String = ip_address.path_join("verify_access_key")
	#var access_string: String = LOCAL_ADDRESS.format([port]) + "verify_access_key"
	hydrus_requester.request(url, get_hydrus_headers(key))
	
	var response: Array = await hydrus_requester.request_completed

	var headers = parse_hydrus_headers(response[2])

	if response[0] != OK:
		SingletonManager.TagIt.log_message(
				"Hydrus Response: " + str(response[0]),
				SingletonManager.TagIt.LogLevel.INFO)
	else:
		if headers.server.begins_with("client api"):
			var json = JSON.new()
			json.parse(response[3].get_string_from_utf8())
			var parsed = json.get_data()
			
			if response[1] == 200:
				if parsed["basic_permissions"].has(3.0):
					if SingletonManager.TagIt.settings.hydrus_port != port:
						SingletonManager.TagIt.settings.hydrus_port = port
					if SingletonManager.TagIt.settings.hydrus_key != key:
						SingletonManager.TagIt.settings.hydrus_key = key
					SingletonManager.TagIt.log_message(
							"Successfully connected to Hydrus",
							SingletonManager.TagIt.LogLevel.INFO)
					return true
				else:
					SingletonManager.TagIt.log_message(
						"Key doesn't have Search/Fetch permissions (3)",
						SingletonManager.TagIt.LogLevel.ERROR
					)
			else:
				SingletonManager.TagIt.log_message(
					"Hydrus Exception: " + str(parsed["error"]) + "\n, " + str(parsed["exception_type"]),
					SingletonManager.TagIt.LogLevel.ERROR)
	return false


func request_hydrus_permissions(port: int) -> String:
	var ip_address: String = LOCAL_ADDRESS % port
	var url: String = ip_address.path_join("request_new_permissions?name=TagIt%20-%20Tag%20List%20Assistant&basic_permissions=%5B3%5D")
	#var request_url: String = LOCAL_ADDRESS.format([str(port)]) + "request_new_permissions?name=TagIt%20-%20Tag%20List%20Assistant&basic_permissions=%5B3%5D"
	
	SingletonManager.TagIt.log_message(
		"Requesting Hydrus access key.",
		SingletonManager.TagIt.LogLevel.INFO)
	
	var request_error := hydrus_requester.request(url)
	
	if request_error != OK:
		SingletonManager.TagIt.log_message(
			"HTTP response (Hydrus): " + "\nCouldn't create request. Error: " + str(request_error),
			SingletonManager.TagIt.LogLevel.INFO)
		return ""
	
	var client_response: Array = await hydrus_requester.request_completed
	
	SingletonManager.TagIt.log_message(
		"HTTP response (Hydrus): " + str(client_response[0]) + "\nHydrus response: " + str(client_response[1]),
		SingletonManager.TagIt.LogLevel.INFO)
	
	if client_response[0] != OK or client_response[1] != 200:
		return ""
	
	var json: JSON = JSON.new()
	
	json.parse(client_response[3].get_string_from_utf8())
	
	return json.data["access_key"]


func on_request_pressed() -> void:
	settings_request_api_btn.disabled = true
	settings_connect_api_btn.disabled = true
	
	var access_key: String = await request_hydrus_permissions(int(settings_port_spn_bx.value))
	
	if not access_key.is_empty():
		settings_key_ln_edt.text = access_key
	
	settings_request_api_btn.disabled = false
	settings_connect_api_btn.disabled = false


func on_category_deleted(id: int) -> void:
	SingletonManager.TagIt.delete_category(id)


func on_thumbnail_size_changed(size_idx: int) -> void:
	SingletonManager.TagIt.settings.wiki_thumbnail_size = size_idx
	match size_idx:
		0:
			wiki_gallery.set_thumbnail_size(Vector2i(100, 100))
		1:
			wiki_gallery.set_thumbnail_size(Vector2i(150, 150))
		2:
			wiki_gallery.set_thumbnail_size(Vector2i(300, 300))
		3:
			wiki_gallery.set_thumbnail_size(Vector2i(600, 600))


func on_wiki_search_button_pressed() -> void:
	on_wiki_searched(wiki_search_ln_edt.text)


func on_wiki_searched(search_text: String) -> void:
	var wiki_search: String = search_text.strip_edges().to_lower()
	_current_wiki_search = wiki_search
	wiki_gallery.clear_gallery()
	wiki_search_ln_edt.editable = false
	wiki_search_btn.disabled = true
	
	if SingletonManager.TagIt.has_tag(wiki_search) and SingletonManager.TagIt.has_tag_data(wiki_search):
		var tag_data := SingletonManager.TagIt.get_tag_data(SingletonManager.TagIt.get_tag_id(wiki_search))
		wiki_title_lbl.text = Strings.title_case(tag_data["tag"])
		wiki_rtl.text = tag_data["description"]
		wiki_cat_lbl.text = SingletonManager.TagIt.get_category_column(tag_data["category"], "name")
		wiki_prio_lbl.text = str(tag_data["priority"])
		
		if tag_data["parents"].is_empty():
			wiki_parents_container.visible = false
		else:
			var parents: Dictionary = SingletonManager.TagIt.get_tags_name(tag_data["parents"])
			wiki_parents_label.text = ", ".join(parents.values())
			wiki_parents_container.visible = true
		
		if tag_data["aliases"].is_empty():
			wiki_aliases_container.visible = false
		else:
			var aliases: Dictionary = SingletonManager.TagIt.get_tags_name(tag_data["aliases"])
			wiki_aliases_label.text = ", ".join(aliases.values())
			wiki_aliases_container.visible = true
		
		wiki_section_separator.visible = wiki_parents_container.visible or wiki_aliases_container.visible
		wiki_panel.update_focus()
		if SingletonManager.TagIt.settings.load_wiki_images and hydrus_connected:
			wiki_reload_images_button.disabled = true
			thumbnail_size_changer.disabled = true
			var files = await search_hydrus_files(
					Array([wiki_search], TYPE_STRING, &"", null),
					SingletonManager.TagIt.settings.wiki_images)
			
			get_thumbnails(files)
		else:
			wiki_search_ln_edt.editable = true
			wiki_search_btn.disabled = false
		
	else:
		wiki_rtl.clear()
		wiki_search_ln_edt.editable = true
		wiki_search_btn.disabled = false
		wiki_title_lbl.text = "[ No Wiki Entry ]"
		wiki_parents_container.visible = false
		wiki_aliases_container.visible = false
		wiki_section_separator.visible = false
		wiki_cat_lbl.text = "[No Category]"
		wiki_prio_lbl.text = "[N/A]"
		wiki_panel.update_focus()


func on_frames_loading_finished() -> void:
	wiki_search_ln_edt.editable = true
	wiki_search_btn.disabled = false
	loading_thumbnails = false


func on_tag_updated(tag_id: int) -> void:
	var tag_data := SingletonManager.TagIt.get_tag_data(tag_id)
	var categories := SingletonManager.TagIt.get_category_data(tag_data["category"])
	var group_name: String = SingletonManager.TagIt.get_tag_group_data(tag_data["group"])["name"] if 0 < tag_data["group"] else ""
	
	tag_search_container.update_table_tag(
		tag_id,
		tag_data["tag"],
		categories["name"],
		tag_data["category"],
		str(tag_data["priority"]),
		group_name,
		tag_data["group"],
		tag_data["is_valid"])


func on_website_changed(_ig_a: Variant = null, _ig_b: Variant = null) -> void:
	tagger_container.validate_site_count()


func on_group_deleted(group_id: int) -> void:
	SingletonManager.TagIt.remove_tag_group(group_id)


func on_set_group_desc(id: int) -> void:
	var new_desc_window = SET_DESC_DIALOG.instantiate()
	add_child(new_desc_window)
	new_desc_window.set_desc(
			SingletonManager.TagIt.get_tag_group_cell(id, "description"))
	new_desc_window.show()
	new_desc_window.focus_first()
	
	var response: Array = await new_desc_window.dialog_finished
	if response[0]:
		SingletonManager.TagIt.set_group_desc(id, response[1])
	new_desc_window.queue_free()


func on_set_category_desc(id: int) -> void:
	var new_desc_window = SET_DESC_CATEGORY_DIALOG.instantiate()
	add_child(new_desc_window)
	new_desc_window.set_desc(SingletonManager.TagIt.get_category_column(id, "description"))
	new_desc_window.set_prefix(SingletonManager.TagIt.get_hydrus_category_prefix(id))
	new_desc_window.show()
	new_desc_window.focus_first()
	
	var response: Array = await new_desc_window.dialog_finished
	if response[0]:
		SingletonManager.TagIt.update_category(id, {"description": response[1]})
		if response[2].is_empty():
			SingletonManager.TagIt.remove_hydrus_category_prefix(id)
		else:
			SingletonManager.TagIt.set_hydrus_category_prefix(
				id,
				response[2])
	
	new_desc_window.queue_free()


func on_set_category_color(id: int, initial: String) -> void:
	var color_dialog := COLOR_PICKER_DIALOG.instantiate()
	add_child(color_dialog)
	color_dialog.set_color(initial)
	color_dialog.show()
	color_dialog.focus_first()
	
	var response: Array = await color_dialog.dialog_finished
	
	if response[0]:
		SingletonManager.TagIt.set_category_icon_color(id, response[1])
		tagger_container.set_category_color(id, response[1])
	
	color_dialog.queue_free()


func on_create_icon_pressed() -> void:
	var new_icon_select := ICON_SELECTION_DIALOG.instantiate()
	add_child(new_icon_select)
	new_icon_select.show()
	new_icon_select.focus_first()
	var response: Array = await new_icon_select.icon_finished
	if response[0]:
		SingletonManager.TagIt.save_icon(response[1], response[2])
		generate_icon_range()
		settings_category_tree.icon_range = icon_range.size() - 1
		settings_category_tree.icon_string = generate_icon_string()
	new_icon_select.queue_free()


func generate_icon_string() -> String:
	var icons: Array[String] = []
	for icon_id in icon_range:
		icons.append(SingletonManager.TagIt.get_icon_name(icon_id))
	return ",".join(icons)


func on_delete_icon(id: int) -> void:
	SingletonManager.TagIt.delete_icon(id)
	
	generate_icon_range()
	settings_category_tree.icon_string = generate_icon_string()
	settings_category_tree.icon_range = icon_range.size() - 1


func on_new_site_pressed() -> void:
	var new_site_dialog := SITE_CONFIRMATION_DIALOG.instantiate()
	add_child(new_site_dialog)
	new_site_dialog.show()
	new_site_dialog.focus_first()
	var response = await new_site_dialog.site_concluded
	if response[0]:
		var site_id: int = SingletonManager.TagIt.create_site(response[1], response[2], response[3], response[4])
		settings_sites_tree.add_site(response[1], site_id)
	new_site_dialog.queue_free()


func _on_website_activated(site: int) -> void:
	var website_data: Dictionary = SingletonManager.TagIt.get_site_data(site)
	
	var whitespace_readable: String = website_data["whitespace"]
	var separator_readable: String = website_data["separator"]
	
	whitespace_readable = whitespace_readable.replace("\t", "\\t").replace("\n", "\\n")
	separator_readable = separator_readable.replace("\t", "\\t").replace("\n", "\\n")
	
	var new_site_dialog := SITE_CONFIRMATION_DIALOG.instantiate()
	new_site_dialog.is_create = false
	add_child(new_site_dialog)
	new_site_dialog.site_name_ln_edt.text = website_data["name"]
	new_site_dialog.whitespace_ln_edt.text = whitespace_readable
	new_site_dialog.separator_ln_edit.text = separator_readable
	new_site_dialog.use_prefix_btn.button_pressed = website_data["use_prefix"]
	new_site_dialog.show()
	new_site_dialog.focus_first()
	var response = await new_site_dialog.site_concluded
	new_site_dialog.queue_free()
	if not response[0]:
		return
	var n: String = response[1]
	var w: String = response[2]
	var s: String = response[3]
	var p: bool = response[4]
	
	var d_n: bool = n != website_data["name"]
	var d_w: bool = w != website_data["whitespace"]
	var d_s: bool = s != website_data["separator"]
	var d_p: bool = p != website_data["use_prefix"]
	
	var rows_to_update: Dictionary = {}
	
	if d_n:
		rows_to_update["name"] = n
	if d_w:
		rows_to_update["whitespace"] = w
	if d_s:
		rows_to_update["separator"] = s
	if d_p:
		rows_to_update["use_prefix"] = p
	
	if not rows_to_update.is_empty():
		SingletonManager.TagIt.update_site(site, rows_to_update)


func on_new_tag_pressed() -> void:
	var new_tag_dialog := NEW_TAG_DIALOG.instantiate()
	add_child(new_tag_dialog)
	new_tag_dialog.show()
	new_tag_dialog.focus_first()
	
	var dialog_response: Array = await new_tag_dialog.creation_finished
	
	if dialog_response[0]:
		if SingletonManager.TagIt.has_tag(dialog_response[1]) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(dialog_response[1])):
			load_and_select_tag(SingletonManager.TagIt.get_tag_id(dialog_response[1]))
		else:
			create_tag(dialog_response[1])
	
	new_tag_dialog.queue_free()


func create_tag(tag_name: String) -> void:
	SingletonManager.TagIt.create_tag(tag_name, 1, "", 0)
	var tag_id: int = SingletonManager.TagIt.get_tag_id(tag_name)
	load_and_select_tag(tag_id)
	open_tag_editor(tag_id)


func on_search_text_submitted(search: String) -> void:
	var clean_search: String = search.strip_edges().to_lower()
	all_tags_tree.clear_tags()
	if clean_search.is_empty():
		tag_search_container.set_search_results(Array([], TYPE_INT, &"", null))
		return
	
	var search_mode: int = 0
	
	if clean_search == DataManager.SEARCH_WILDCARD:
		search_mode = -1
	else:
		if clean_search.begins_with(DataManager.SEARCH_WILDCARD):
			search_mode += 1
			clean_search = clean_search.trim_prefix(DataManager.SEARCH_WILDCARD)
		
		if clean_search.ends_with(DataManager.SEARCH_WILDCARD):
			search_mode += 2
			clean_search = clean_search.trim_suffix(DataManager.SEARCH_WILDCARD)
	
	match search_mode:
		-1:# Show all
			tag_search_container.set_search_results(SingletonManager.TagIt.get_all_tag_ids(true))
		0: # Exact
			if SingletonManager.TagIt.has_tag(clean_search) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(clean_search)):
				tag_search_container.set_search_results(
						Array(
								[SingletonManager.TagIt.get_tag_id(clean_search)],
								TYPE_INT,
								&"",
								null))
		1: # Ends with
			var id_array: Array[int] = []
			var tags := SingletonManager.TagIt.get_tags(
					SingletonManager.TagIt.get_all_tag_ids(true))
			for tag in tags:
				if SingletonManager.TagIt.get_tag_name(tag).ends_with(clean_search):
					id_array.append(tag)
			tag_search_container.set_search_results(id_array)
		2: # Begins with
			var id_array: Array[int] = []
			var tags := SingletonManager.TagIt.get_tags(
					SingletonManager.TagIt.get_all_tag_ids(true))
			for tag in tags:
				if tags[tag]["name"].begins_with(clean_search):
					id_array.append(tag)
			tag_search_container.set_search_results(id_array)
		3: # Contains
			var id_array: Array[int] = []
			var tags := SingletonManager.TagIt.get_tags(
					SingletonManager.TagIt.get_all_tag_ids(true))
			for tag in tags:
				if tags[tag]["name"].contains(clean_search):
					id_array.append(tag)
			tag_search_container.set_search_results(id_array)


func append_search(tag_name: String, tag_id: int = 0) -> void:
	var id: int = tag_id if 0 < tag_id else SingletonManager.TagIt.get_tag_id(tag_name)
	
	var tag_data := SingletonManager.TagIt.get_tag_data(id)
	
	tag_search_container.add_tag_to_table(
			id,
			tag_data["tag"],
			tag_data["category"],
			tag_data["priority"],
			tag_data["group"],
			tag_data["is_valid"])


func load_and_select_tag(tag_id: int) -> void:
	all_tags_search_ln_edt.text = SingletonManager.TagIt.get_tag_name(tag_id) 
	all_tags_tree.clear_tags()
	append_search("", tag_id)
	all_tags_tree.select_tag(0)


func open_tag_editor(tag_id: int) -> void:
	if 0 < tag_id:
		tag_editor.load_tag(tag_id)
	
	tag_editor.visible = true
	tag_searcher.visible = false


func close_tag_editor() -> void:
	tag_editor.visible = false
	tag_searcher.visible = true
	
	tag_editor.clear_all()


func hide_all_sections() -> void:
	tagger_container.visible = false
	wiki_panel.visible = false
	tags_panel.visible = false
	tools_panel.visible = false
	settings_panel.visible = false


func on_tab_changed(tab:int) -> void:
	hide_all_sections()
	
	match tab:
		0:
			tagger_container.visible = true
		1:
			wiki_panel.visible = true
		2:
			tags_panel.visible = true
		3:
			tools_panel.visible = true
		4:
			settings_panel.visible = true


func generate_icon_range() -> void:
	icon_range.clear()
	for id in SingletonManager.TagIt.icons.keys():
		icon_range.append(int(id))
	
	icon_range.sort()


func on_category_icon_changed(cat_id: int, range_selected: int) -> void:
	var r: int = icon_range[range_selected]
	SingletonManager.TagIt.set_category_icon(
			cat_id,
			r)
	tagger_container.set_category_icon(
			cat_id,
			SingletonManager.TagIt.get_icon_texture(r))


func on_expand_api_pressed() -> void:
	settings_api_container.visible = not settings_api_container.visible
	settings_expand_api_btn.icon = EXPAND_UP_ICON if settings_api_container.visible else EXPAND_DOWN_ICON


func on_api_toggle_changed(is_enabled: bool) -> void:
	SingletonManager.TagIt.settings.load_wiki_images = is_enabled
	wiki_image_side.visible = is_enabled
	settings_port_spn_bx.editable = is_enabled
	settings_key_ln_edt.editable = is_enabled
	settings_image_load_spn_bx.editable = is_enabled
	settings_request_api_btn.disabled = not is_enabled
	settings_connect_api_btn.disabled = not is_enabled


func _on_request_tags_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.request_suggestions = is_toggled
	settings_relevancy_spn_bx.editable = is_toggled


func on_create_category_pressed() -> void:
	var dialog_window := CREATE_GROUP_DIALOG.instantiate()
	dialog_window.title = "Create Category..."
	add_child(dialog_window)
	dialog_window.show()
	dialog_window.focus_first()
	
	var result = await dialog_window.dialog_finished
	
	if result[0]:
		SingletonManager.TagIt.create_category(result[1], result[2])
	
	dialog_window.queue_free()


func on_create_group_pressed() -> void:
	var dialog_window = CREATE_GROUP_DIALOG.instantiate()
	add_child(dialog_window)
	dialog_window.show()
	dialog_window.focus_first()
	
	var result = await dialog_window.dialog_finished
	
	if result[0]:
		settings_groups_tree.create_group(
			result[1],
			SingletonManager.TagIt.create_tag_group(result[1], result[2]))
	
	dialog_window.queue_free()


func on_dialog_cancel_free(dialog: AcceptDialog) -> void:
	dialog.queue_free()
func on_cancelled(dialog: FileDialog) -> void:
	dialog.queue_free()


func on_log_created(msg: String) -> void:
	if 201 < settings_logs_txt_edt.get_line_count():
		var first_line: String = settings_logs_txt_edt.get_line(0)
		settings_logs_txt_edt.text = settings_logs_txt_edt.text.substr(first_line.length()).strip_edges(true, false)
	
	if 1000 < msg.length():
		settings_logs_txt_edt.text += msg.substr(0, 1000) + "\n"
	else:
		settings_logs_txt_edt.text += msg + "\n"


func on_edit_tag_pressed(tag_id: int) -> void:
	open_tag_editor(tag_id)


func on_export_tag_pressed(tag_id: int) -> void:
	var new_dialog := FileDialog.new()
	add_child(new_dialog)
	new_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	new_dialog.add_filter("*.json", "JSON File")
	new_dialog.access = FileDialog.ACCESS_FILESYSTEM
	new_dialog.use_native_dialog = true
	new_dialog.file_selected.connect(on_export_success.bind(tag_id, new_dialog))
	new_dialog.canceled.connect(on_dialog_cancel_free.bind(new_dialog))
	new_dialog.show()


func on_delete_tag_pressed(tag_id: int) -> void:
	SingletonManager.TagIt.delete_tag_data(tag_id)


# These need testing. A lot.
func on_export_success(path: String, tag_id: int, dialog: FileDialog) -> void:
	db_tag_to_json(tag_id, path)
	dialog.queue_free()


func json_tag_to_db(data: Dictionary, overwrite: bool = false) -> void:
	var clean_name: String = data["name"].strip_edges().to_lower()
	
	if clean_name.is_empty():
		SingletonManager.TagIt.log_message(
				"[JSON PARSER] JSON data doesn't have a tag name.",
				DataManager.LogLevel.ERROR)
		notify_import(false, false)
		return
	
	var icon_id: int = 0
	var cat_id: int = 0
	var group_id: int = 0
	var group_sugg_data: Dictionary = SingletonManager.TagIt.get_tag_groups()
	var category_data: Dictionary = SingletonManager.TagIt.get_categories()
	
	for icon in SingletonManager.TagIt.icons.keys():
		if Strings.nocasecmp_equal(SingletonManager.TagIt.icons[icon]["name"], data["category"]["icon_name"]):
			icon_id = icon
			break
	
	for category_id in category_data:
		if Strings.nocasecmp_equal(category_data[category_id]["name"], data["category"]["name"]):
			cat_id = category_id
			break
	
	for group in group_sugg_data:
		if Strings.nocasecmp_equal(group["name"], data["group"]):
			group_id = group["id"]
			break
	
	if 0 == icon_id:
		var new_img := Image.new()
		new_img.load_webp_from_buffer(PackedByteArray(data["category"]["category_icon"]))
		icon_id = SingletonManager.TagIt.save_icon(data["category"]["icon_name"], new_img)
	
	if cat_id == 0:
		cat_id = SingletonManager.TagIt.create_category(data["category"]["name"], data["category"]["description"])
		SingletonManager.TagIt.set_category_icon_color(
				cat_id,
				data["category"]["category_color"] if Color.html_is_valid(data["category"]["category_color"]) else "ffffff")
		SingletonManager.TagIt.set_category_icon(cat_id, icon_id)
	
	if group_id == 0 and not data["group"].is_empty():
		group_id = SingletonManager.TagIt.create_tag_group(data["group"], data["group_desc"])
		group_sugg_data[group_id] = {"name": data["group"], "description": data["group_desc"]}
	
	if SingletonManager.TagIt.has_tag(clean_name) and SingletonManager.TagIt.has_tag_data(clean_name):
		if overwrite:
			var tag_id: int = SingletonManager.TagIt.get_tag_id(clean_name)
			SingletonManager.TagIt.update_tag_data(
					tag_id,
					{
						"category_id": cat_id,
						"group_id": group_id,
						"description": data["wiki"],
						"tooltip": data["tooltip"],
						"priority": data["priority"]
					})
			SingletonManager.TagIt.remove_aliases_to(tag_id)
			if not data["aliases"].is_empty():
				SingletonManager.TagIt.add_aliases(data["aliases"], clean_name)
			SingletonManager.TagIt.remove_all_parents_from(tag_id)
			if not data["parents"].is_empty():
				SingletonManager.TagIt.add_parents(tag_id, Array(data["parents"], TYPE_STRING, &"", null))
			SingletonManager.TagIt.remove_all_group_suggestions(tag_id)
			var _new_suggestions: Array[int] = []
			
			for group_sugg_text in data["group_suggestions"]:
				for grp_id in group_sugg_data:
					if Strings.nocasecmp_equal(group_sugg_text, group_sugg_data[grp_id]["name"]):
						_new_suggestions.append(grp_id)
			if not _new_suggestions.is_empty():
				SingletonManager.TagIt.add_group_suggestions(tag_id, _new_suggestions)
		else:
			SingletonManager.TagIt.log_message(
					"[TagIt] Tag \"" + clean_name + "\" already in DB. Skipping.",
					SingletonManager.TagIt.LogLevel.INFO)
		notify_import()
		return

	SingletonManager.TagIt.create_tag(
			clean_name,
			cat_id,
			data["wiki"],
			group_id,
			data["tooltip"])
	
	var new_tag_id: int = SingletonManager.TagIt.get_tag_id(clean_name)
	
	if not data["aliases"].is_empty():
		SingletonManager.TagIt.add_aliases(data["aliases"], clean_name)
	
	if not data["parents"].is_empty():
		SingletonManager.TagIt.add_parents(new_tag_id, data["parents"])
	if not data["suggestions"].is_empty():
		SingletonManager.TagIt.add_suggestions(new_tag_id, data["suggestions"])
	SingletonManager.TagIt.set_tag_priority(new_tag_id, data["priority"])
	SingletonManager.TagIt.set_tag_valid(new_tag_id, data["is_valid"])
	
	var _new_tag_suggestions: Array[int] = []
	for group_sugg_text in data["group_suggestions"]:
		for grp_id in group_sugg_data:
			if Strings.nocasecmp_equal(group_sugg_text, group_sugg_data[grp_id]["name"]):
				_new_tag_suggestions.append(grp_id)
	if not _new_tag_suggestions.is_empty():
		SingletonManager.TagIt.add_group_suggestions(new_tag_id, _new_tag_suggestions)
	
	notify_import()


func notify_import(multiple: bool = false, success: bool = true) -> void:
	var message := preload("res://scenes/dialogs/message_confirmation_dialog.gd").new()
	message.title = "Finished"
	if success:
		message.message = "Tags Imported" if multiple else "Tag Imported"
	else:
		message.message = "Failed to import tags" if multiple else "Failed to import tag"
	add_child(message)
	message.show()
	await message.dialog_finished
	message.queue_free()


func json_group_to_db(json_result: Dictionary, overwrite: bool = false) -> void:
	var cats_data := SingletonManager.TagIt.get_categories()
	var groups_data := SingletonManager.TagIt.get_tag_groups() # id: Dict
	
	var all_icons: Dictionary = {} # name: -> ID
	var all_cats: Dictionary = {}
	var all_groups: Dictionary = {} # name.to_lower() -> ID
	
	var json_icons: Dictionary = {} # idx -> ID
	var json_cats: Dictionary = {}
	var json_groups: Dictionary = {}
	
	for icon_id in SingletonManager.TagIt.icons:
		all_icons[SingletonManager.TagIt.icons[icon_id]["name"].to_lower()] = icon_id
	for cat in cats_data:
		all_cats[cats_data[cat]["name"].to_lower()] = cat
	for group_id in groups_data:
		all_groups[groups_data[group_id]["name"].to_lower()] = group_id
	
	var icon_idx: int = -1
	for icon_dict in json_result["icons"]:
		icon_idx += 1
		
		if typeof(icon_dict) != TYPE_DICTIONARY:
			continue
		
		var has_icon: bool = false
		for i_name in all_icons.keys():
			if Strings.nocasecmp_equal(i_name, icon_dict["name"]):
				has_icon = true
				json_icons[icon_idx] = all_icons[i_name]
				break
		
		if has_icon:
			continue
		
		var image_data: Image = Image.new()
		if image_data.load_webp_from_buffer(icon_dict["bits"]) == OK:
			json_icons[icon_idx] = SingletonManager.TagIt.save_icon(icon_dict["name"], image_data)
	
	var cat_idx: int = -1
	for category_dict: Dictionary in json_result["categories"]:
		cat_idx += 1
		if not typeof(category_dict) == TYPE_DICTIONARY or not category_dict.has_all(["name", "color", "icon", "description"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] Category with index " + str(cat_idx) + " is missing data.", SingletonManager.TagIt.LogLevel.ERROR)
			continue
		
		var id_found: bool = false
		for cat_name in all_cats.keys():
			if Strings.nocasecmp_equal(cat_name, category_dict["name"]):
				id_found = true
				json_cats[cat_idx] = all_cats[cat_name]
				break
		
		if id_found:
			continue
		
		var category_id: int = SingletonManager.TagIt.create_category(category_dict["name"], category_dict["description"])
		var valid_color: String = category_dict["color"] if Color.html_is_valid(category_dict["color"]) else "ffffff"
		json_cats[cat_idx] = category_id
		
		SingletonManager.TagIt.set_category_icon_color(category_id, valid_color)
		
		if json_icons.has(int(category_dict["icon"])):
			SingletonManager.TagIt.set_category_icon(category_id, json_icons[int(category_dict["icon"])])
	
	var group_idx: int = -1
	for group_dict in json_result["groups"]:
		group_idx += 1
		
		if typeof(group_dict) != TYPE_DICTIONARY or not group_dict.has_all(["name", "description"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] Group with index " + str(group_idx) + " is missing some data.", SingletonManager.TagIt.LogLevel.ERROR)
			continue # Skipping incomplete dictionaries.
		
		var group_id: int = 0
		var has_group: bool = false
		for group_name in all_groups:
			if Strings.nocasecmp_equal(group_name, group_dict["name"]):
				has_group = true
				json_groups[group_idx] = all_groups[group_name]
				break
		
		if has_group:
			continue
		
		group_id = SingletonManager.TagIt.create_tag_group(group_dict["name"], group_dict["description"])
		all_groups[group_dict["name"].to_lower()] = group_id #{"name": group_dict["name"], "description": group_dict["description"]}
		json_groups[group_idx] = group_id
	
	var empty_tags: Dictionary = {}
	for empty_entry in json_result["tags"]:
		for empty_parent:String in empty_entry["parents"]:
			if empty_parent.is_empty() or SingletonManager.TagIt.has_tag(empty_parent):
				continue
			var key: String = empty_parent.left(1)
			if not empty_tags.has(key):
				empty_tags[key] = Array([], TYPE_STRING, &"", null)
			if Arrays.binary_search(empty_tags[key], empty_parent) == -1:
				Arrays.insert_sorted_asc(empty_tags[key], empty_parent)
		
		for empty_suggestion:String in empty_entry["suggestions"]:
			if empty_suggestion.is_empty() or SingletonManager.TagIt.has_tag(empty_suggestion):
				continue
			var key: String = empty_suggestion.left(1)
			if not empty_tags.has(key):
				empty_tags[key] = Array([], TYPE_STRING, &"", null)
			if Arrays.binary_search(empty_tags[key], empty_suggestion) == -1:
				Arrays.insert_sorted_asc(empty_tags[key], empty_suggestion)
		
		for empty_alias:String in empty_entry["aliases"]:
			if empty_alias.is_empty() or SingletonManager.TagIt.has_tag(empty_alias):
				continue
			var key: String = empty_alias.left(1)
			if not empty_tags.has(key):
				empty_tags[key] = Array([], TYPE_STRING, &"", null)
			if Arrays.binary_search(empty_tags[key], empty_alias) == -1:
				Arrays.insert_sorted_asc(empty_tags[key], empty_alias)
	
	var new_tags: Array[String] = []
	for entry_key in empty_tags:
		new_tags.append_array(empty_tags[entry_key])
	
	if not new_tags.is_empty():
		SingletonManager.TagIt.create_empty_tags(new_tags)
	
	var tag_idx: int = -1
	for tag:Dictionary in json_result["tags"]:
		if typeof(tag) != TYPE_DICTIONARY or not tag.has_all(["name", "priority", "is_valid", "category", "wiki", "tooltip", "group", "aliases", "parents", "suggestions", "group_suggestions"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] Tag with index " + str(tag_idx) + " is missing some data.", SingletonManager.TagIt.LogLevel.ERROR)
			continue # Skipping incomplete dictionaries.
		
		var clean_tag: String = tag["name"].strip_edges().to_lower()
		var group_id: int = 0 if not json_groups.has(int(tag["group"])) else json_groups[int(tag["group"])]
		var cat_id: int = 1 if not json_cats.has(int(tag["category"])) else json_cats[int(tag["category"])]
		
		if SingletonManager.TagIt.has_tag(clean_tag) and SingletonManager.TagIt.has_tag_data(clean_tag):
			if overwrite:
				var _tag_id: int = SingletonManager.TagIt.get_tag_id(clean_tag)
				SingletonManager.TagIt.update_tag(_tag_id, {"is_valid": tag["is_valid"]})
				@warning_ignore("incompatible_ternary")
				SingletonManager.TagIt.update_tag_data(
					_tag_id,
					{
						"group_id": group_id if 0 < group_id else null,
						"description": tag["wiki"],
						"tooltip": tag["tooltip"],
						"priority": tag["priority"],
						"category_id": cat_id
					})
				
				SingletonManager.TagIt.remove_aliases_to(_tag_id)
				SingletonManager.TagIt.remove_all_parents_from(_tag_id)
				SingletonManager.TagIt.remove_all_group_suggestions(_tag_id)
				SingletonManager.TagIt.remove_all_suggestions(_tag_id)
			else:
				SingletonManager.TagIt.log_message(
					"[TagIt] Tag \"" + clean_tag + "\" already in DB. Skipping.",
					SingletonManager.TagIt.LogLevel.INFO)
				continue
		else:
			SingletonManager.TagIt.create_tag(
				clean_tag,
				cat_id,
				tag["wiki"],
				group_id,
				tag["tooltip"].strip_edges(),
				tag["priority"])
	
		var tag_id: int = SingletonManager.TagIt.get_tag_id(clean_tag)
		var group_suggestions: Array[int] = []
	
		for group_text in tag["group_suggestions"]:
			for group_name in all_groups:
				if Strings.nocasecmp_equal(group_text, group_name):
					group_suggestions.append(all_groups[group_name])
					break
		
		if not tag["parents"].is_empty():
			SingletonManager.TagIt.add_parents(tag_id, Array(tag["parents"], TYPE_STRING, &"", null))
		
		if not tag["suggestions"].is_empty():
			SingletonManager.TagIt.add_suggestions(
					tag_id,
					Array(
								tag["suggestions"],
								TYPE_STRING,
								&"",
								null))
		if not group_suggestions.is_empty():
			SingletonManager.TagIt.add_group_suggestions(tag_id, group_suggestions)
		 
		if not tag["aliases"].is_empty():
			SingletonManager.TagIt.add_aliases(
					Array(tag["aliases"],
							TYPE_STRING,
							&"",
							null),
					clean_tag)
	
	notify_import(true)


func db_tag_to_json(tag_id: int, path: String) -> void:
	var data := SingletonManager.TagIt.get_tag_data(tag_id)
	var groups := SingletonManager.TagIt.get_tag_groups()
	var cat_data := SingletonManager.TagIt.get_category_data(data["category"])
	var group_suggestions: PackedStringArray = []
	var json_file := FileAccess.open(path, FileAccess.WRITE)
	
	for grp_sugg in data["suggested_groups"]:
		group_suggestions.append(groups[grp_sugg]["name"])
	
	var int_array: Array[int] = []
	int_array.assign(SingletonManager.TagIt.get_icon_texture(SingletonManager.TagIt.get_category_icon_id(data["category"])).get_image().save_webp_to_buffer())
	
	var tag = {
		"type": 0,
		"name": data["tag"],
		"priority": data["priority"],
		"is_valid": data["is_valid"],
		"category": {
			"name": cat_data["name"],
			"category_icon": int_array,
			"icon_name": SingletonManager.TagIt.get_icon_name(cat_data["icon_id"]),
			"category_color": cat_data["icon_color"],
			"description": cat_data["description"]},
		"wiki": data["description"],
		"tooltip": data["tooltip"],
		"group": groups[data["group"]]["name"] if 0 < data["group"] else "",
		"group_desc": groups[data["group"]]["description"] if 0 < data["group"] else "",
		"parents": SingletonManager.TagIt.get_tags_name(data["parents"]).values(),
		"suggestions": SingletonManager.TagIt.get_tags_name(data["suggestions"]).values(),
		"aliases": SingletonManager.TagIt.get_tags_name(data["aliases"]).values(),
		"group_suggestions": group_suggestions}
	
	json_file.store_string(JSON.stringify(tag, "\t"))
	json_file.close()


func db_group_to_json(tag_ids: Array[int], path: String) -> void:
	var icons: Array[Dictionary] = []
	var categories: Array[Dictionary] = []
	var tags: Array[Dictionary] = [] 
	var groups: Array[Dictionary] = []
	
	var all_groups: Dictionary = SingletonManager.TagIt.get_tag_groups()
	var all_categories: Dictionary = SingletonManager.TagIt.get_categories()
	
	for tag in tag_ids:
		var data: Dictionary = SingletonManager.TagIt.get_tag_data(tag)

		var category: int = data["category"]
		var icon: String = SingletonManager.TagIt.get_icon_name(SingletonManager.TagIt.get_category_icon_id(category)).to_lower()
		var group_name: String = all_groups[data["group"]]["name"] if 0 < data["group"] else ""
		var cat_name: String = all_categories[category]["name"]
		var group_suggestions: PackedStringArray = []
		
		var _icon_idx: int = -1
		var _group_idx: int = -1
		var _cat_idx: int = -1
		
		for grp_sugg in data["suggested_groups"]:
			group_suggestions.append(all_groups[grp_sugg]["name"])
		
		var has_icon: bool = false
		
		for icon_dict in icons:
			_icon_idx += 1
			if Strings.nocasecmp_equal(icon_dict["name"], icon):
				has_icon = true
				break
		
		if not has_icon:
			_icon_idx = icons.size()
			var bits: Array[int] = []
			bits.assign(SingletonManager.TagIt.get_icon_texture(all_categories[category]["icon_id"]).get_image().save_webp_to_buffer())
			icons.append({"name": icon, "bits": bits})
		
		var has_category: bool = false
		
		for cat_dict in categories:
			_cat_idx += 1
			if Strings.nocasecmp_equal(cat_dict["name"], cat_name):
				has_category = true
				break
		
		if not has_category:
			_cat_idx = categories.size()
			categories.append({
				"name": cat_name,
				"color": all_categories[category]["icon_color"],
				"icon": _icon_idx,
				"description": all_categories[category]["description"]})
		
		var has_group: bool = false
		
		if not group_name.is_empty():
			for group_dict in groups:
				_group_idx += 1
				if Strings.nocasecmp_equal(group_dict["name"], group_name):
					has_group = true
					break
			
			if not has_group:
				_group_idx = groups.size()
				groups.append({
					"name": group_name,
					"description": all_groups[data["group"]]["description"]})
		
		tags.append({
			"name": data["tag"],
			"priority": data["priority"],
			"is_valid": data["is_valid"],
			"category": _cat_idx,
			"wiki": data["description"],
			"tooltip": data["tooltip"],
			"group": _group_idx,
			"aliases": SingletonManager.TagIt.get_tags_name(data["aliases"]).values(),
			"parents": SingletonManager.TagIt.get_tags_name(data["parents"]).values(),
			"suggestions": SingletonManager.TagIt.get_tags_name(data["suggestions"]).values(),
			"group_suggestions": group_suggestions})
	
	var json_data: Dictionary = {
		"type": 1,
		"icons": icons,
		"categories": categories,
		"groups": groups,
		"tags": tags}
	
	var json_file := FileAccess.open(path,FileAccess.WRITE)
	var json_text: String = JSON.stringify(json_data, "\t")
	
	json_file.store_string(json_text)
	json_file.close()


func heal_json_dict(dict: Dictionary) -> void:
	var band_aid: Dictionary = {
		"name": "",
		"priority": 0,
		"is_valid": true,
		"category": {
			"name": "generic",
			"description": "",
			"category_icon": SingletonManager.TagIt.get_icon_texture(1).get_image().save_webp_to_buffer(),
			"icon_name": "Generic",
			"category_color": "ffffff"},
		"wiki": "",
		"tooltip": "",
		"group": "",
		"group_desc": "",
		"parents": Array([], TYPE_STRING, &"", null),
		"suggestions": Array([], TYPE_STRING, &"", null),
		"aliases": Array([], TYPE_STRING, &"", null),
		"group_suggestions": Array([], TYPE_STRING, &"", null)}
	
	dict.merge(band_aid)
	dict["category"].merge(band_aid["category"])
	dict["name"] = dict["name"].strip_edges().to_lower()
	if typeof(dict["priority"]) != TYPE_INT and typeof(dict["priority"]) != TYPE_FLOAT:
		dict["priority"] = 0
	if typeof(dict["is_valid"]) != TYPE_BOOL:
		dict["is_valid"] = true
	if typeof(dict["category"]["name"]) != TYPE_STRING or typeof(dict["category"]["description"]) != TYPE_STRING or typeof(dict["category"]["category_icon"]) != TYPE_ARRAY or typeof(dict["category"]["icon_name"]) != TYPE_STRING or typeof(dict["category"]["category_color"]) != TYPE_STRING:
		dict["category"] = band_aid["category"]
	
	for byte_idx in range(dict["category"]["category_icon"].size()):
		var type = typeof(dict["category"]["category_icon"][byte_idx])
		if type == TYPE_INT:
			continue
		elif type == TYPE_FLOAT:
			dict["category"]["category_icon"][byte_idx] = int(dict["category"]["category_icon"][byte_idx])
		elif type != TYPE_INT and type != TYPE_FLOAT:
			dict["category"] = band_aid["category"]
			break
		
		if 255 < typeof(dict["category"]["category_icon"][byte_idx]) or typeof(dict["category"]["category_icon"][byte_idx]) < 0:
			dict["category"] = band_aid["category"]
			break

	if typeof(dict["wiki"]) != TYPE_STRING:
		dict["wiki"] = ""
	if typeof(dict["tooltip"]) != TYPE_STRING:
		dict["tooltip"] = ""
	if typeof(dict["group"]) != TYPE_STRING:
		dict["group"] = ""
	if typeof(dict["group_desc"]) != TYPE_STRING:
		dict["group_desc"] = ""
	if typeof(dict["parents"]) != TYPE_ARRAY:
		dict["parents"] = Array([], TYPE_STRING, &"", null)
	else:
		var typed_array: Array[String] = []
		for parent in dict["parents"]:
			if typeof(parent) == TYPE_STRING:
				typed_array.append(parent)
		
		dict["parents"] = typed_array
	
	if typeof(dict["suggestions"]) != TYPE_ARRAY:
		dict["suggestions"] = Array([], TYPE_STRING, &"", null)
	else:
		var typed_array: Array[String] = []
		for suggestion in dict["suggestions"]:
			if typeof(suggestion) == TYPE_STRING:
				typed_array.append(suggestion)
		
		dict["suggestions"] = typed_array
	
	if typeof(dict["aliases"]) != TYPE_ARRAY:
		dict["aliases"] = Array([], TYPE_STRING, &"", null)
	else:
		var typed_array: Array[String] = []
		for alias in dict["aliases"]:
			if typeof(alias) == TYPE_STRING:
				typed_array.append(alias)
		dict["aliases"] = typed_array
		
	if typeof(dict["group_suggestions"]) != TYPE_ARRAY:
		dict["group_suggestions"] = Array([], TYPE_STRING, &"", null)
	else:
		var typed_array: Array[String] = []
		for group in dict["group_suggestions"]:
			if typeof(group) == TYPE_STRING:
				typed_array.append(group)
		dict["group_suggestions"] = typed_array


func _on_clear_logs_pressed() -> void:
	settings_logs_txt_edt.clear()


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _save_required:
			if _saving:
				return
			backup_timer.paused = true
			var save_confirmation := preload("res://scenes/dialogs/unsaved_confirmation_dialog.gd").new()
			add_child.call_deferred(save_confirmation)
			await save_confirmation.ready
			save_confirmation.show()
			var result: int = await save_confirmation.dialog_finished
			
			if result == 0: # Save selected. Show Saving and wait for dialog
				var texture: Texture2D = tagger_container.get_project_thumbnail_image()
				
				if loaded_project._uuid.is_empty():
					_saving = true
					var process_in: bool = selector.is_processing_input() if selector != null else false
					if process_in:
						selector.set_process_input(false)
					
					var extra_saver := PROJECTS_CONTAINER_VERTICAL.instantiate()
					extra_saver.group_save_enabled = true
					extra_saver.use_descriptions = false
					extra_saver.editable_cards = true
					extra_saver.use_search = false
					extra_saver.use_save = true
					extra_saver.dim_background = true
					add_child(extra_saver)
					extra_saver.add_project(
						current_title,
						"",
						texture,
						current_project_uuid,
						0)
					extra_saver.play_intro()
					await extra_saver.intro_finished
					extra_saver.set_emit_signals(true)
					var save_result: Array = await extra_saver.save_finished
					extra_saver.set_emit_signals(false)
					if not save_result[0]: # Save was cancelled
						extra_saver.play_outro()
						await extra_saver.outro_finished
						extra_saver.visible = false
						extra_saver.queue_free()
						if selector != null:
							selector.set_process_input(process_in)
						_saving = false
						backup_timer.paused = false
						return
					
					loaded_project._uuid = UUID.generate_new()
					loaded_project.title = save_result[1]
				save_current_project()
			
			elif result == 2: # Cancel
				save_confirmation.queue_free()
				backup_timer.paused = false
				return
		
		_close_signaled = true
		if not backup_timer.is_stopped():
			backup_timer.stop()
		# Signal the subthread to stop work
		hydrus_images.signal_close.emit() 
		
		if loading_image:
			hydrus_large_image.cancel_request()
		
		if 0 < hydrus_images.working:
			get_tree().create_timer(5.0).timeout.connect(func(): _cleanup_timeout = true)
			
			while 0 < hydrus_images.working and not _cleanup_timeout:
				await get_tree().process_frame # Wait before checking again
		
		if 0 < hydrus_images.working:
			SingletonManager.TagIt.log_silent(
					"Program closed while subthread was still working",
					DataManager.LogLevel.INFO)
		
		tagger_container.clean_undo()
		hydrus_images.queue_free.call_deferred()
		project_backup.safe_exit()
		SingletonManager.TagIt.quit_request()
