extends Control


var icon_range: Array[int] = []


# ----- Scene Preload -----
const CREATE_GROUP_DIALOG = preload("res://scenes/dialogs/create_group_dialog.tscn")
const NEW_TAG_DIALOG = preload("res://scenes/dialogs/new_tag_dialog.tscn")
const ICON_SELECTION_DIALOG = preload("res://scenes/dialogs/icon_selection_dialog.tscn")
const SITE_CONFIRMATION_DIALOG = preload("res://scenes/dialogs/site_confirmation_dialog.tscn")
const SET_DESC_DIALOG = preload("res://scenes/dialogs/set_desc_dialog.tscn")
const SET_DESC_CATEGORY_DIALOG = preload("res://scenes/dialogs/set_desc_category_dialog.tscn")
const COLOR_PICKER_DIALOG = preload("res://scenes/dialogs/color_picker_dialog.tscn")
const NEW_ALIAS_CONFIRM_DIALOG = preload("res://scenes/dialogs/new_alias_confirm_dialog.tscn")
const IMAGE_FILE_SELECTOR = preload("res://scenes/image_file_selector.tscn")
const VERTICAL_CARD_CONTAINER = preload("res://scenes/vertical_card_container.tscn")
const SUGGENSTION_BLACKLIST = preload("res://scenes/suggenstion_blacklist.tscn")
const TEXT_LOADER = preload("res://scenes/text_loader.tscn")
const ALL_TAGS_PANEL = preload("res://scenes/all_tags_panel.tscn")
const TAG_EXPORTER = preload("res://scenes/tag_exporter.tscn")
const ABOUT_WINDOW = preload("res://scenes/help_window.tscn")
const TAG_PRIORITIZER = preload("res://scenes/tag_prioritizer.tscn")
# ----- Script Preload -----
const LineConfirmationDialog = preload("res://scenes/dialogs/line_confirmation_dialog.gd")
const UnsavedConfirmationDialog = preload("res://scenes/dialogs/unsaved_confirmation_dialog.gd")
# ----- Resource Preload -----
const EXPAND_DOWN_ICON = preload("res://icons/expand_down_icon.svg")
const EXPAND_UP_ICON = preload("res://icons/expand_up_icon.svg")
# ----- Hydrus -----
const LOCAL_ADDRESS: String = "http://127.0.0.1:{0}/"
const HEADER: String = "Hydrus-Client-API-Access-Key:"
# ----- eSix -----
const ESIX_SEARCH_URL: String = "https://e621.net/wiki_pages/show_or_new?title="

# Endpoints
const THUMBNAILS: String = "get_files/thumbnail?file_id="
const SEARCH: String = "get_files/search_files?tags="
const HYDRUS_FILE_ENDPOINT: String = "get_files/file?file_id="

@export var search_time: float = 0.3


var selector: Control = null:
	set(new_selector):
		selector = new_selector
		_block_events = selector != null
		menu_button.set_disable_shortcuts(selector != null)
		help_button.set_disable_shortcuts(selector != null)
var alt_lists: Array[Array] = []
var current_alt: int = 0

var current_project: int = -1
var current_title: String = ""

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
var _saving: bool = false # Used if a save instance is on screen.
var _save_required: bool = false
var _image_changed: bool = false
var _block_events: bool = false
var _help_pressed: bool = false
var _suggestion_blacklist: PackedStringArray = []
var custom_order_list: Dictionary = {}
var prio_list_node: Control = null

# ----- Windows -----
@onready var tagger_container: PanelContainer = $MainContainer/TaggerContainer
@onready var wiki_panel: PanelContainer = $MainContainer/WikiPanel
@onready var tags_panel: PanelContainer = $MainContainer/TagsPanel
@onready var tools_panel: PanelContainer = $MainContainer/ToolsPanel
@onready var settings_panel: PanelContainer = $MainContainer/SettingsPanel
# -------------------
# ----- Tag Containers -----
@onready var tags_tree: Tree = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/CurrentTagsContainer/TagsTree
# --------------------------

# --- Quick Access ---
@onready var template_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/TemplateBtn
# --------------------


# ----- Tagger -----
@onready var tagger_site_opt_btn: OptionButton = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/BtnCotnainer/SiteOptBtn
@onready var generate_list_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/BtnCotnainer/GenerateBtn
@onready var project_image: TextureRect = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/ImageContainer/PanelContainer/ProjectImage
@onready var open_img_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/OpenImgBtn
@onready var clear_img_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/ImageContainer/BtnCtnr/ClearImgBtn
@onready var tags_label: RichTextLabel = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/TextPanel/TextMargin/TagsLabel
@onready var export_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/ButtonsContainer/ExportBtn
@onready var copy_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/ButtonsContainer/CopyBtn
@onready var alt_opt_btn: OptionButton = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/CurrentTagsContainer/AltSelectContainer/AltOptBtn
@onready var new_alt_list_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/NewAltListBtn
@onready var delete_alt_list_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/CurrentTagsContainer/AltSelectContainer/DeleteAltListBtn
@onready var open_project_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/OpenBtn
@onready var save_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/SaveBtn
@onready var new_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/NewBtn
@onready var wizard_btn: Button = $MainContainer/MenuMargin/MenuContainer/QuickAccessCtnr/WizardBtn
@onready var search_tag_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/CurrentTagsContainer/BarItems/SearchTagBtn
@onready var generate_tag_list_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/BtnCotnainer/GenerateBtn
@onready var groups_suggestions_tree: Tree = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/SuggestionContainer/GroupsTree
@onready var tagger_suggestion_tree: Tree = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/SuggestionContainer/SuggestionTree
@onready var alt_select_container: HBoxContainer = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/CurrentTagsContainer/AltSelectContainer
@onready var list_version_container: HBoxContainer = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/ListVersionContainer
@onready var generate_version_opt_btn: OptionButton = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/ListVersionContainer/GenerateVersionOptBtn
@onready var menu_button: MenuButton = $MainContainer/MenuMargin/MenuContainer/MenuButtonCont/MenuButton
@onready var help_button: MenuButton = $MainContainer/MenuMargin/MenuContainer/MenuButtonCont/HelpButton
@onready var change_prio_btn: Button = $MainContainer/TaggerContainer/MainMargin/Containers/EndContainer/TagsField/TagsPanel/TagsContainer/ButtonsContainer/ChangePrioBtn
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
#@onready var settings_logs_label: RichTextLabel = $MainContainer/SettingsPanel/SettingsMargin/MainContainer/LogsContainer/PanelContainer/MarginContainer/LogsLabel
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

# -----------------------

@onready var tab_bar: TabBar = $MainContainer/MenuMargin/MenuContainer/TabBar
@onready var add_tag_ln_edt: LineEdit = $MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer/CurrentTagsContainer/BarItems/AddTagLnEdt


func _ready() -> void:
	get_window().min_size = Vector2i(1280, 720)
	hide_all_sections()
	tab_bar.current_tab = 0
	on_tab_changed(0)
	tag_searcher.visible = true
	tag_editor.visible = false
	settings_api_container.visible = false
	alt_select_container.visible = false
	delete_alt_list_btn.disabled = true
	list_version_container.visible = false
	
	wiki_section_separator.visible = false
	wiki_parents_container.visible = false
	wiki_aliases_container.visible = false
	
	alt_lists.append([])
	
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
		settings_icons_tree.add_icon(icon, SingletonManager.TagIt.get_icon_name(icon), SingletonManager.TagIt.get_icon_texture(icon))
	
	for site in sites:
		settings_sites_tree.add_site(
			sites[site]["name"], site)
	
	for group in groups:
		settings_groups_tree.create_group(groups[group]["name"], groups[group]["description"], group)
	
	var menu_popup: PopupMenu = menu_button.get_popup()
	
	menu_popup.set_item_shortcut(0, load("res://shortcuts/new_list_shortcut.tres"))
	menu_popup.set_item_shortcut(1, load("res://shortcuts/new_alt_list_shortcut.tres"))
	menu_popup.set_item_shortcut(2, load("res://shortcuts/save_list_shortcut.tres"))
	menu_popup.set_item_shortcut(3, load("res://shortcuts/save_list_as_shortcut.tres"))
	menu_popup.set_item_shortcut(4, load("res://shortcuts/open_list_shortcut.tres"))
	menu_popup.set_item_shortcut(10, load("res://shortcuts/add_template.tres"))
	menu_popup.set_item_shortcut(11, load("res://shortcuts/import_from_text_shortcut.tres"))
	menu_popup.set_item_shortcut(13, load("res://shortcuts/quit_shortcut.tres"))
	
	help_button.get_popup().set_item_shortcut(0, load("res://shortcuts/about_shortcut.tres"))
	
	generate_list_btn.disabled = SingletonManager.TagIt.get_site_count() == 0
	
	# --- Loading and applying TagIt saved settings ---
	wiki_search_ln_edt.use_timer = SingletonManager.TagIt.settings.use_autofill
	add_tag_ln_edt.use_timer = SingletonManager.TagIt.settings.use_autofill
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
	settings_image_load_spn_bx.value = SingletonManager.TagIt.settings.wiki_images
	settings_request_sugg_chk_btn.button_pressed = SingletonManager.TagIt.settings.request_suggestions
	settings_relevancy_spn_bx.value = SingletonManager.TagIt.settings.suggestion_relevancy
	settings_relevancy_spn_bx.editable = settings_request_sugg_chk_btn.button_pressed
	wiki_image_side.visible = settings_load_img_chk_btn.button_pressed
	thumbnail_size_changer.select(SingletonManager.TagIt.settings.wiki_thumbnail_size)
	on_thumbnail_size_changed(thumbnail_size_changer.selected)
	$MainContainer/TaggerContainer/MainMargin/Containers/TagsContainer.size.x = SingletonManager.TagIt.settings.tag_container_width
	tagger_suggestion_tree.size.y = SingletonManager.TagIt.settings.suggestions_height
	
	# --- Tagger ---
	open_img_btn.pressed.connect(on_select_image_pressed)
	clear_img_btn.pressed.connect(on_clear_image_pressed)
	export_btn.pressed.connect(export_tags)
	copy_btn.pressed.connect(copy_tags_field)
	generate_tag_list_btn.pressed.connect(on_generate_tag_list_btn_pressed)
	template_btn.pressed.connect(on_menu_button_id_selected.bind(9))
	new_alt_list_btn.pressed.connect(on_menu_button_id_selected.bind(14))
	alt_opt_btn.item_selected.connect(on_alt_list_selected)
	delete_alt_list_btn.pressed.connect(on_delete_list_pressed)
	tab_bar.tab_changed.connect(on_tab_changed)
	add_tag_ln_edt.text_submitted.connect(add_tag)
	tagger_suggestion_tree.suggestions_activated.connect(on_suggestions_activated)
	groups_suggestions_tree.suggestions_activated.connect(on_suggestions_activated)
	open_project_btn.pressed.connect(on_menu_button_id_selected.bind(2))
	save_btn.pressed.connect(on_menu_button_id_selected.bind(1))
	new_btn.pressed.connect(on_menu_button_id_selected.bind(0))
	wizard_btn.pressed.connect(on_menu_button_id_selected.bind(8))
	tagger_suggestion_tree.suggestions_deleted.connect(blacklist_tags)
	menu_button.get_popup().id_pressed.connect(on_menu_button_id_selected)
	add_tag_ln_edt.timer_finished.connect(on_search_timer_timeout)
	search_tag_btn.pressed.connect(on_search_all_tags_pressed)
	help_button.get_popup().id_pressed.connect(on_help_id_pressed)
	change_prio_btn.pressed.connect(on_menu_button_id_selected.bind(17))
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
	
	SingletonManager.eSixAPI.suggestions_found.connect(on_esix_api_suggestions_found)
	
	SingletonManager.TagIt.website_created.connect(on_website_changed)
	SingletonManager.TagIt.website_deleted.connect(on_website_changed)
	SingletonManager.TagIt.tag_updated.connect(on_tag_updated)
	SingletonManager.TagIt.message_logged.connect(on_log_created)
	
	SingletonManager.TagIt.hide_splash()
	
	if SingletonManager.TagIt.settings.has_valid_hydrus_login():
		hydrus_connected = await connect_to_hydrus(
			SingletonManager.TagIt.settings.hydrus_port,
			SingletonManager.TagIt.settings.hydrus_key)
		if hydrus_connected:
			settings_port_spn_bx.value = SingletonManager.TagIt.settings.hydrus_port
			settings_key_ln_edt.text = SingletonManager.TagIt.settings.hydrus_key


func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		if _save_required:
			if _saving:
				return
			var save_confirmation := preload("res://scenes/dialogs/unsaved_confirmation_dialog.gd").new()
			add_child.call_deferred(save_confirmation)
			await save_confirmation.ready
			save_confirmation.show()
			var result: int = await save_confirmation.dialog_finished
			if result == 0: # Save selected. Show Saving and wait for dialog
				if -1 < current_project:
					save_alt_list(current_alt)
					var alts: Array[Dictionary] = []
					for idx in range(generate_version_opt_btn.item_count):
						alts.append({
							"name": generate_version_opt_btn.get_item_text(idx),
							"list": alt_lists[idx + 1].duplicate()})
					
					var projects := TagItProjectResource.get_projects()
					var image_path: String = projects.projects[current_project]["image_path"]
					
					if project_image.texture == null and not image_path.is_empty():
						OS.move_to_trash(TagItProjectResource.get_thumbnails_path() + image_path)
						image_path = ""
					elif project_image != null and _image_changed:
						project_image.texture.get_image().save_jpg(TagItProjectResource.get_thumbnails_path() + image_path)
					
					projects.overwrite_project(
							current_project,
							current_title,
							alt_lists[0],
							tagger_suggestion_tree.get_all_suggestions_text(),
							groups_suggestions_tree.get_all_groups(),
							image_path,
							alts,
							custom_order_list.duplicate())
					projects.save()
				else:
					_saving = true
					var process_in: bool = selector.is_processing_input() if selector != null else false
					if process_in:
						selector.set_process_input(false)
					
					var extra_saver := VERTICAL_CARD_CONTAINER.instantiate()
					extra_saver.group_save_enabled = true
					extra_saver.use_descriptions = false
					extra_saver.editable_cards = true
					extra_saver.use_search = false
					extra_saver.use_save = true
					extra_saver.dim_background = true
					add_child(extra_saver)
					extra_saver.play_intro()
					await extra_saver.intro_finished
					extra_saver.queue_card(
						current_title,
						"",
						project_image.texture,
						0)
					extra_saver.create_queued_cards()
					await extra_saver.cards_displayed
					extra_saver.set_emit_signals(true)
					var save_result: Array = await extra_saver.save_finished
					extra_saver.set_emit_signals(false)
					if save_result[0]: 
						var projects := TagItProjectResource.get_projects()
						var alts: Array[Dictionary] = []
						
						save_alt_list(current_alt)
						for idx in range(generate_version_opt_btn.item_count):
							alts.append({
								"name": generate_version_opt_btn.get_item_text(idx),
								"list": alt_lists[idx + 1].duplicate()})
						
						var image_path: String = ""
						if project_image.texture != null:
							image_path = Strings.random_string64() + ".webp"
							project_image.texture.get_image().save_webp(TagItProjectResource.get_thumbnails_path() + image_path)
							
						projects.create_project(
								save_result[1],
								alt_lists[0],
								tagger_suggestion_tree.get_all_suggestions_text(),
								groups_suggestions_tree.get_all_groups(),
								image_path,
								alts,
								custom_order_list.duplicate())
						
						projects.save()
					else:# Save was cancelled
						extra_saver.play_outro()
						await extra_saver.outro_finished
						extra_saver.visible = false
						extra_saver.queue_free()
						if selector != null:
							selector.set_process_input(process_in)
						_saving = false
						return
			elif result == 2: # Cancel
				save_confirmation.queue_free()
				return
		SingletonManager.TagIt.quit_request()


func _list_changed() -> void:
	if not _save_required:
		_save_required = true


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
		return
	
	if json.parse(file_string) != OK:
		SingletonManager.TagIt.log_message(
				str(
						"There was an error while trying to parse tag data on line ",
						json.get_error_line(),
						".\nError: ",
						json.get_error_message()),
				DataManager.LogLevel.ERROR)
		return
	
	if typeof(json.data) != TYPE_DICTIONARY:
		SingletonManager.TagIt.log_message(
				"The data structure in the provided JSON couldn't be loaded.",
				DataManager.LogLevel.ERROR)
		return
		
	var data: Dictionary = json.data.duplicate()

	if not json.data.has("type"):
		SingletonManager.TagIt.log_message(
				"[JSON PARSER] JSON missing type.",
				DataManager.LogLevel.ERROR)
		return
	
	if data["type"] == 0:
		if not data.has_all(["aliases", "category", "group", "group_desc", "group_suggestions", "is_valid", "name", "parents", "priority", "suggestions", "tooltip", "type", "wiki"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] JSON data is a dictionary but is missing some keys.", SingletonManager.TagIt.LogLevel.ERROR)
			return
	
		if not typeof(data["category"]) == TYPE_DICTIONARY or not data["category"].has_all(["category_color", "category_icon", "description", "icon_name", "name"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] JSON data category is missing some data.", SingletonManager.TagIt.LogLevel.ERROR)
			return
		
		json_tag_to_db(data, overwrite)
		
	elif data["type"] == 1:
		if not data.has_all(["categories", "groups", "icons", "tags", "type"]):
			SingletonManager.TagIt.log_message("[JSON PARSER] JSON data is a dictionary but is missing some keys.", SingletonManager.TagIt.LogLevel.ERROR)
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


#func on_tag_line_changed(_new_text: String) -> void:
	#if add_tag_ln_edt.items_visible():
		#add_tag_ln_edt.hide_items()
	#if not SingletonManager.TagIt.settings.use_autofill:
		#return
	#search_timer.start()


func on_search_timer_timeout() -> void:
	if not add_tag_ln_edt.has_focus():
		return
	
	add_tag_ln_edt.clear_list()
	var clean_text: String = add_tag_ln_edt.text.strip_edges().to_lower()
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
		results = SingletonManager.TagIt.search_for_tag_contains(clean_text, add_tag_ln_edt.item_limit, true)
	elif suffix:
		results = SingletonManager.TagIt.search_for_tag_suffix(clean_text, add_tag_ln_edt.item_limit, true)
	else:
		results = SingletonManager.TagIt.search_for_tag_prefix(clean_text, add_tag_ln_edt.item_limit, true)
	
	var id_results: Array[int] = Array(SingletonManager.TagIt.get_tags_ids(results).values(), TYPE_INT, &"", null)
	
	var tags_with_aliases: Dictionary = SingletonManager.TagIt.get_aliases_consequent_names_from(id_results)
	
	if not results.is_empty():
		for tag in results:
			if tags_with_aliases.has(SingletonManager.TagIt.get_tag_id(tag)):
				add_tag_ln_edt.add_item(
						tag,
						tags_with_aliases[SingletonManager.TagIt.get_tag_id(tag)])
			else:
				add_tag_ln_edt.add_item(tag)
		
		add_tag_ln_edt.show_items()


#func on_wiki_line_changed(_new_text: String) -> void:
	#if wiki_search_ln_edt.items_visible():
		#wiki_search_ln_edt.hide_items()
	#if not SingletonManager.TagIt.settings.use_autofill:
		#return
	#wiki_timer.start()


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
		results = SingletonManager.TagIt.search_for_tag_contains(clean_text, wiki_search_ln_edt.item_limit, true, true)
	elif suffix:
		results = SingletonManager.TagIt.search_for_tag_suffix(clean_text, wiki_search_ln_edt.item_limit, true, true)
	else:
		results = SingletonManager.TagIt.search_for_tag_prefix(clean_text, wiki_search_ln_edt.item_limit, true, true)
	
	if not results.is_empty():
		for tag in results:
			wiki_search_ln_edt.add_item(tag)
		wiki_search_ln_edt.show_items()


func sort_tags_alphabetical() -> void:
	var children: Array[TreeItem] = tags_tree.get_root().get_children()
	children.sort_custom(_sort_tree_alphabetical)


func _sort_tree_alphabetical(a: TreeItem, b: TreeItem) -> bool:
	return a.get_text(0).naturalnocasecmp_to(b.get_text(0)) < 0


func add_suggestion(suggestion: String) -> void:
	if not _suggestion_blacklist.has(suggestion) and not tagger_suggestion_tree.has_suggestion(suggestion):
		tagger_suggestion_tree.add_suggestion(suggestion)


func on_wizard_finished(tags: Array[String]) -> void:
	for tag in tags:
		add_tag(tag)
	_block_events = false
	selector.queue_free()
	selector = null


func on_wizard_cancelled() -> void:
	selector.queue_free()
	selector = null


func on_esix_wiki_search() -> void:
	OS.shell_open(
		ESIX_SEARCH_URL + wiki_search_ln_edt.text.strip_edges())


func create_alt_list() -> void:
	var name_list := LineConfirmationDialog.new()
	add_child(name_list)
	name_list.allow_empty = false
	name_list.title = "Name Alt List..."
	name_list.show()
	name_list.focus_line_edit()
	var result: Array = await name_list.dialog_finished
	if result[0]:
		alt_lists.append([])
		alt_opt_btn.add_item(result[1])
		generate_version_opt_btn.add_item(result[1])
		if not alt_select_container.visible:
			alt_select_container.visible = true
			list_version_container.visible = true
		_list_changed()
		alt_opt_btn.select(alt_opt_btn.item_count - 1)
		on_alt_list_selected(alt_opt_btn.item_count - 1)
	name_list.queue_free()


func on_delete_list_pressed() -> void:
	alt_lists.remove_at(current_alt)
	alt_opt_btn.remove_item(current_alt)
	generate_version_opt_btn.remove_item(current_alt - 1)
	current_alt -= 1
	alt_opt_btn.select(current_alt)
	generate_version_opt_btn.select(current_alt - 1)
	load_alt_list(current_alt)
	if alt_opt_btn.item_count == 1:
		alt_select_container.visible = false
		list_version_container.visible = false


func on_alt_list_selected(idx: int) -> void:
	var search_suggestions: bool = SingletonManager.TagIt.settings.request_suggestions
	SingletonManager.TagIt.settings.request_suggestions = false
	save_alt_list(current_alt)
	current_alt = idx
	load_alt_list(idx)
	delete_alt_list_btn.disabled = idx == 0
	SingletonManager.TagIt.settings.request_suggestions = search_suggestions


func load_alt_list(idx: int) -> void:
	clear_main_tag_list()
	for tag in alt_lists[idx]:
		add_tag(tag, false)


func save_alt_list(index: int) -> void:
	var list_tags: Array[String] = []
	for tag in tags_tree.get_root().get_children():
		list_tags.append(tag.get_text(0))
	alt_lists[index] = list_tags


func clear_main_tag_list() -> void:
	for tag in tags_tree.get_root().get_children():
		tag.free()


func clear_suggestions() -> void:
	for tag in tagger_suggestion_tree.get_root().get_children():
		tag.free()


func clear_group_suggestions() -> void:
	for tag in groups_suggestions_tree.get_root().get_children():
		tag.free()


func save_current_project_indexed() -> void:
	save_alt_list(current_alt)
	var alts: Array[Dictionary] = []
	for idx in range(generate_version_opt_btn.item_count):
		alts.append({
			"name": generate_version_opt_btn.get_item_text(idx),
			"list": alt_lists[idx + 1].duplicate()})
	
	var projects := TagItProjectResource.get_projects()
	var image_path: String = projects.projects[current_project]["image_path"]
	
	if project_image.texture == null and not image_path.is_empty():
		OS.move_to_trash(TagItProjectResource.get_thumbnails_path() + image_path)
		image_path = ""
	elif project_image != null and _image_changed:
		project_image.texture.get_image().save_webp(TagItProjectResource.get_thumbnails_path() + image_path)
	
	projects.overwrite_project(
			current_project,
			projects.projects[current_project]["name"],
			alt_lists[0],
			tagger_suggestion_tree.get_all_suggestions_text(),
			groups_suggestions_tree.get_all_groups(),
			image_path,
			alts,
			custom_order_list.duplicate())
	projects.save()
	_save_required = false


func instantiate_save_selector() -> void:
	_saving = true
	selector = VERTICAL_CARD_CONTAINER.instantiate()
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
	selector.play_intro()
	await selector.intro_finished
	selector.queue_card(
		current_title,
		"",
		project_image.texture,
		0)
	selector.create_queued_cards()
	await selector.cards_displayed
	selector.set_emit_signals(true)


func instance_project_loader_selector() -> void:
	selector = IMAGE_FILE_SELECTOR.instantiate()
	selector.use_descriptions = false
	selector.dim_background = true
	add_child(selector)
	selector.set_emit_signals(false)
	selector.card_selected.connect(on_selector_project_selected)
	selector.close_pressed.connect(on_selector_close_pressed)
	selector.card_deleted.connect(on_selector_project_deleted)
	selector.play_intro()
	await selector.intro_finished
	var saves := TagItProjectResource.get_projects()
	
	for project in saves.projects:
		var texture: ImageTexture = null
		if not project["image_path"].is_empty():
			var img := Image.load_from_file(TagItProjectResource.get_thumbnails_path() + project["image_path"])
			texture = ImageTexture.create_from_image(img)
		selector.queue_card(
			project["name"],
			"",
			texture)
	if selector.has_queued_cards():
		selector.create_queued_cards()
		await selector.cards_displayed
	selector.set_emit_signals(true)


func instantiate_text_loader() -> void:
	selector = TEXT_LOADER.instantiate()
	selector.tags_split.connect(on_split_tags)
	selector.split_cancelled.connect(on_split_cancelled)
	add_child(selector)


func on_split_cancelled() -> void:
	selector.visible = false
	selector.queue_free()
	selector = null


func on_split_tags(tags: PackedStringArray) -> void:
	for tag in tags:
		add_tag(tag)
	selector.visible = false
	selector.queue_free()
	selector = null


func instance_preset_selector() -> void:
	selector = IMAGE_FILE_SELECTOR.instantiate()
	selector.dim_background = true
	add_child(selector)
	selector.set_emit_signals(false)
	selector.card_selected.connect(on_selector_template_selected)
	selector.close_pressed.connect(on_selector_close_pressed)
	selector.card_deleted.connect(on_selector_template_erased)
	selector.play_intro()
	await selector.intro_finished
	
	var templates := TemplateResource.get_templates()
	
	for template in templates.templates:
		var texture: ImageTexture = null
		if not template["thumbnail"].is_empty():
			var img := Image.load_from_file(TemplateResource.get_thumbnail_path() + template["thumbnail"])
			texture = ImageTexture.create_from_image(img)
		selector.queue_card(
				template["title"],
				template["description"],
				texture)
	if selector.has_queued_cards():
		selector.create_queued_cards()
		await selector.cards_displayed
	selector.set_emit_signals(true)


func instantiate_wizard() -> void:
	selector = preload("res://scenes/wizard.tscn").instantiate()
	selector.wizard_finished.connect(on_wizard_finished)
	selector.wizard_cancelled.connect(on_wizard_cancelled)
	add_child(selector)
	selector.set_project_texture(project_image.texture)


func on_menu_button_id_selected(id: int) -> void:
	match id:
		0: # New List
			if _block_events:
				return
			if _save_required:
				var save_confirmation := preload("res://scenes/dialogs/unsaved_confirmation_dialog.gd").new()
				add_child(save_confirmation)
				save_confirmation.show()
				var result: int = await save_confirmation.dialog_finished
				if result == 0: # Save selected. Show Saving and wait for dialog
					if -1 < current_project:
						save_current_project_indexed()
					else:
						if selector != null:
							SingletonManager.TagIt.log_message(
								"[ERROR] Loading tried to save but selector is in memory.",
								SingletonManager.TagIt.LogLevel.ERROR)
							save_confirmation.queue_free()
							return
						
						instantiate_save_selector()
						
						await selector.outro_finished
						
						if _save_required: # Save was cancelled
							save_confirmation.queue_free()
							return
				elif result == 2: # Cancel
					save_confirmation.queue_free()
					return
				save_confirmation.queue_free()
			new_list()
		1: # Save:
			if _block_events:
				return
			
			if -1 < current_project:
				save_current_project_indexed()
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
			sort_tags_alphabetical()
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
			create_alt_list()
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
			prio_list_node = TAG_PRIORITIZER.instantiate()
			tagger_container.add_child(prio_list_node)
			prio_list_node.priority_tags = custom_order_list
			prio_list_node.close_pressed.connect(on_prio_list_close)


func on_prio_list_close() -> void:
	prio_list_node.queue_free()
	prio_list_node = null


func on_help_id_pressed(id: int) -> void:
	match id:
		0:
			if _help_pressed or _block_events:
				return
			_help_pressed = true
			var new_help := ABOUT_WINDOW.instantiate()
			add_child(new_help)
			await new_help.close_pressed
			new_help.visible = false
			new_help.queue_free()
			_help_pressed = false


func instantiate_blacklist() -> void:
	selector = SUGGENSTION_BLACKLIST.instantiate()
	selector.suggestion_blacklist = _suggestion_blacklist
	selector.blacklist_submitted.connect(on_new_blacklist)
	selector.blacklist_cancelled.connect(on_blacklist_cancelled)
	add_child(selector)


func on_blacklist_cancelled() -> void:
	selector.visible = false
	selector.queue_free()
	selector = null


func on_new_blacklist(new_blacklist: PackedStringArray) -> void:
	_suggestion_blacklist = new_blacklist
	selector.visible = false
	selector.queue_free()
	selector = null


func new_list() -> void:
	current_title = ""
	current_project = -1
	_suggestion_blacklist.clear()
	clear_all_tagger()
	_save_required = false


func clear_all_tagger() -> void:
	clear_main_tag_list()
	clear_suggestions()
	clear_group_suggestions()
	project_image.texture = null
	clear_img_btn.disabled = true
	generate_version_opt_btn.clear()
	for alt in range(alt_opt_btn.item_count - 1, 0, -1):
		alt_opt_btn.remove_item(alt)
	delete_alt_list_btn.disabled = true
	tags_label.clear()
	alt_lists.clear()
	alt_lists.append([])
	custom_order_list.clear()
	if prio_list_node != null:
		prio_list_node.priority_tags = {}
	list_version_container.visible = false
	alt_select_container.visible = false


func on_selector_project_saved(title: String) -> void:
	selector.set_emit_signals(false)
	var projects := TagItProjectResource.get_projects()
	var alts: Array[Dictionary] = []
	
	save_alt_list(current_alt)
	
	for idx in range(generate_version_opt_btn.item_count):
		alts.append({
			"name": generate_version_opt_btn.get_item_text(idx),
			"list": alt_lists[idx + 1].duplicate()})
	
	var image_path: String = ""
	
	if project_image.texture != null:
		image_path = Strings.random_string64() + ".webp"
		project_image.texture.get_image().save_webp(TagItProjectResource.get_thumbnails_path() + image_path)
		
	current_project = projects.create_project(
			title,
			alt_lists[0],
			tagger_suggestion_tree.get_all_suggestions_text(),
			groups_suggestions_tree.get_all_groups(),
			image_path,
			alts,
			custom_order_list.duplicate())
	
	projects.save()
	
	current_title = title
	_save_required = false
	selector.stop_queued_cards()
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null


func on_selector_project_selected(project_idx: int) -> void:
	selector.set_emit_signals(false)
	var request_suggestions: bool = SingletonManager.TagIt.settings.request_suggestions
	SingletonManager.TagIt.settings.request_suggestions = false
	
	var projects := TagItProjectResource.get_projects()
	clear_all_tagger()
	
	for tag in projects.projects[project_idx]["tags"]:
		add_tag(tag)
	
	for suggestion in projects.projects[project_idx]["suggestions"]:
		if SingletonManager.TagIt.has_tag(suggestion):
			#var id: int = SingletonManager.TagIt.get_tag_id(suggestion)
			if not tagger_suggestion_tree.has_suggestion(suggestion):
				tagger_suggestion_tree.add_suggestion(suggestion)
		else:
			tagger_suggestion_tree.add_suggestion(suggestion)
	
	var groups := SingletonManager.TagIt.get_groups_and_tags(projects.projects[project_idx]["groups"])
	
	for group_id in groups:
		if not groups_suggestions_tree.has_tag_group(group_id):
			groups_suggestions_tree.add_suggestions(groups[group_id]["group_name"], groups[group_id]["tags"], groups)
	
	if not projects.projects[project_idx]["image_path"].is_empty() and FileAccess.file_exists(TagItProjectResource.get_thumbnails_path() + projects.projects[project_idx]["image_path"]):
		var img := Image.load_from_file(TagItProjectResource.get_thumbnails_path() + projects.projects[project_idx]["image_path"])
		project_image.texture = ImageTexture.create_from_image(img)
	
	if not projects.projects[project_idx]["alt_lists"].is_empty():
		list_version_container.visible = true
		alt_select_container.visible = true
	
	for alt_list_dict in projects.projects[project_idx]["alt_lists"]:
		alt_opt_btn.add_item(alt_list_dict["name"])
		generate_version_opt_btn.add_item(alt_list_dict["name"])
		alt_lists.append(alt_list_dict["list"])
	
	custom_order_list = projects.projects[project_idx]["custom_priorities"].duplicate() if projects.projects[project_idx].has("custom_priorities") else {}
	
	if prio_list_node != null:
		prio_list_node.priority_tags = custom_order_list
	
	selector.stop_queued_cards()
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null
	current_project = project_idx
	current_title = projects.projects[project_idx]["name"]
	_save_required = false
	SingletonManager.TagIt.settings.request_suggestions = request_suggestions


func on_selector_project_deleted(project_idx: int) -> void:
	var projects := TagItProjectResource.get_projects()
	projects.delete_project(project_idx)
	projects.save()
	if current_project == project_idx:
		current_project = -1
		_save_required = true


func on_selector_close_pressed(is_save: bool = false) -> void:
	selector.set_emit_signals(false)
	selector.stop_queued_cards()
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null
	if is_save:
		_saving = false


func on_search_all_tags_pressed() -> void:
	var searcher := ALL_TAGS_PANEL.instantiate()
	searcher.tags_selected.connect(on_search_tags_added)
	searcher.panel_close_pressed.connect(on_searcher_close_pressed.bind(searcher))
	tagger_container.add_child(searcher)
	search_tag_btn.disabled = true


func on_search_tags_added(tags: PackedStringArray) -> void:
	for tag in tags:
		add_tag(tag)


func on_searcher_close_pressed(instance: Control) -> void:
	instance.visible = false
	instance.queue_free()
	search_tag_btn.disabled = false
	


func on_selector_template_selected(template_idx: int) -> void:
	selector.set_emit_signals(false)
	var request_suggestions: bool = SingletonManager.TagIt.settings.request_suggestions
	SingletonManager.TagIt.settings.request_suggestions = false
	var templates := TemplateResource.get_templates()
	var template_data: = templates.get_template(template_idx)
	
	for tag in template_data["tags"]:
		add_tag(tag)
	
	var groups_per_tag: Dictionary = SingletonManager.TagIt.get_groups_and_tags(template_data["groups"])
	
	for group_id in groups_per_tag:
		if not groups_suggestions_tree.has_tag_group(group_id):
			groups_suggestions_tree.add_suggestions(
					groups_per_tag[group_id]["group_name"],
					groups_per_tag[group_id]["tags"],
					group_id)
	
	selector.stop_queued_cards()
	selector.play_outro()
	await selector.outro_finished
	selector.visible = false
	selector.queue_free()
	selector = null
	SingletonManager.TagIt.settings.request_suggestions = request_suggestions


func on_selector_template_erased(template_idx: int) -> void:
	tools_panel.on_template_deleted(template_idx)
	var templates := TemplateResource.get_templates()
	templates.delete_template_thumbnail(template_idx)
	templates.erase_template(template_idx)
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
	add_tag_ln_edt.use_timer = is_toggled


func on_include_invalid_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.include_invalid = is_toggled


func on_blacklist_suggestions_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.blacklist_removed = is_toggled


func on_link_esix_toggled(is_toggled: bool) -> void:
	SingletonManager.TagIt.settings.link_to_esix = is_toggled


func on_generate_tag_list_btn_pressed() -> void:
	var tags: Dictionary = {}
	
	# Getting main list tags
	if current_alt == 0:
		tags = tags_tree.get_tags()
	else:
		var id: Array[int] = []
		var tag: Array[String] = []
		for _tag in alt_lists[0]:
			if SingletonManager.TagIt.has_tag(_tag):
				id.append(SingletonManager.TagIt.get_tag_id(_tag))
			else:
				tag.append(_tag)
		tags["id"] = id
		tags["tag"] = tag
	
	# Alt list index 0 is the main list. More than one means an alt exists.
	# If an alt exists one HAS to be selected.
	if 1 < alt_lists.size():
		if generate_version_opt_btn.selected + 1 == current_alt:
			var tag_data: Dictionary = tags_tree.get_tags()
			Arrays.append_uniques(tags["id"], tag_data["id"])
			Arrays.append_uniques(tags["tag"], tag_data["tag"])
		else:
			for tag in alt_lists[generate_version_opt_btn.selected + 1]:
				if SingletonManager.TagIt.has_tag(tag):
					var id: int = SingletonManager.TagIt.get_tag_id(tag)
					if not tags["id"].has(id):
						tags["id"].append(id)
				else:
					if not tags["tag"].has(tag):
						tags["tag"].append(tag)
	
	var final_tag_ids := SingletonManager.TagIt.get_final_tag_ids(tags["id"])
	var sorted_tags: Dictionary = SingletonManager.TagIt.sort_tag_ids_by_priority(final_tag_ids)
	if not sorted_tags.has(0):
		sorted_tags[0] = Array([], TYPE_INT, &"", null)
	
	# --- Preparing for custom order ---
	var named_ids: Dictionary = {}
	
	for priority in sorted_tags:
		# ID: Name
		var tag_names := SingletonManager.TagIt.get_tags_name(sorted_tags[priority])
		
		for tag_id in tag_names:
			if custom_order_list.has(tag_names[tag_id]):
				named_ids[tag_names[tag_id]] = custom_order_list[tag_names[tag_id]]
			else:
				named_ids[tag_names[tag_id]] = priority
	
	for unid_tag in tags["tag"]:
		if custom_order_list.has(unid_tag):
			named_ids[unid_tag] = custom_order_list[unid_tag]
		else:
			named_ids[unid_tag] = 0
	
	# --- Custom order applied ---
	
	# --- Cramming into a dictionary Priority:[text, tags] ---
	var repeat_priorities: Dictionary = {}
	
	for tag_name in named_ids:
		if not repeat_priorities.has(named_ids[tag_name]):
			repeat_priorities[named_ids[tag_name]] = Array([], TYPE_STRING, &"", null)
		repeat_priorities[named_ids[tag_name]].append(tag_name)
	
	# --- Crammed ---
	
	var priorities: Array = repeat_priorities.keys()
	priorities.sort_custom(Arrays.sort_custom_desc)
	var tags_array: Array[String] = []
	
	for priority in priorities:
		tags_array.append_array(repeat_priorities[priority])
	
	var website_data: Dictionary = SingletonManager.TagIt.get_site_formatting(tagger_site_opt_btn.get_selected_website_id())
	
	for tag_idx in range(tags_array.size()):
		tags_array[tag_idx] = tags_array[tag_idx].replace(" ", website_data["whitespace"])
	
	tags_label.text = website_data["separator"].join(tags_array)


func parse_hydrus_image_headers(headers_array: PackedStringArray) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func get_thumbnails(ids_array: Array) -> void:
	var url_building: String = LOCAL_ADDRESS.format([SingletonManager.TagIt.settings.hydrus_port]) + THUMBNAILS
	
	var frames_to_create: Dictionary = {}
	var headers := get_hydrus_headers()
	
	for pic_id in ids_array:

		hydrus_requester.request(url_building + str(pic_id), headers)
		var response_array = await hydrus_requester.request_completed
		
		if response_array[0] != OK or response_array[1] != 200:
			continue
		
		var _heads: Dictionary = parse_hydrus_image_headers(response_array[2])
		frames_to_create[int(pic_id)] = {
			"data": response_array[3],
			"format": _heads["content-type"].split("/")[1]
			}
		
		
	hydrus_images.create_frames.emit(frames_to_create)
		#hydrus_images.emit_signal.call_deferred("create_frames", response_array[3], _heads["content-type"].split("/")[1])
		#hydrus_images.create_image_texture.call_deferred(response_array[3], _heads["content-type"].split("/")[1])
		#var texture: SpriteFrames = await hydrus_images.frames_created
		
		#return_dictionary[int(pic_id)] = texture.get_frame_texture(&"default", 0)
	
	#return return_dictionary


func on_wiki_frame_created(frames: SpriteFrames, id: int) -> void:
	wiki_gallery.create_image(frames.get_frame_texture(&"default", 0), id)


func on_wiki_thumbnail_pressed(thumbnail_id: int, img_idx: int) -> void:
	if loading_image:
		return
	
	loading_image = true
	wiki_panel.show_spinner()
	var url: String = LOCAL_ADDRESS.format([SingletonManager.TagIt.settings.hydrus_port]) + HYDRUS_FILE_ENDPOINT + str(thumbnail_id)
	
	hydrus_large_image.request(url, get_hydrus_headers())
	var response: Array = await hydrus_large_image.request_completed
	
	if response[0] != OK or response[1] != 200:
		wiki_panel.hide_throbber()
		loading_image = false
		return
	
	var _heads: Dictionary = parse_hydrus_image_headers(response[2])
	hydrus_images.load_full_image.emit(response[3], _heads["content-type"].split("/")[1])
	wiki_panel.image_index = img_idx


func on_wiki_image_loaded(full_image: SpriteFrames, animated: bool) -> void:
	wiki_panel.set_image(full_image, animated)
	loading_image = false


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


func search_hydrus_files(tags_array: Array[String], tag_count: int) -> Array:
	if not hydrus_connected:
		return []
	var request_url: String = LOCAL_ADDRESS.format([SingletonManager.TagIt.settings.hydrus_port]) + SEARCH
	
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
		request_url += tags_to_format.uri_encode() + "&"
	request_url += "file_sort_type=4"
	hydrus_requester.request(request_url, get_hydrus_headers())
	
	var response = await hydrus_requester.request_completed
	
	if response[0] != OK or response[1] != 200:
		SingletonManager.TagIt.log_message(
			"API response was not 0, 200\nResponse: " + str(response[0]) + ", " + str(response[1]),
			SingletonManager.TagIt.LogLevel.WARNING
		)
		return[]
	
	var json = JSON.new()
	json.parse(response[3].get_string_from_utf8())
	var parsed = json.get_data()
	
	return parsed["file_ids"]


func on_connect_to_hydrus() -> void:
	settings_request_api_btn.disabled = true
	settings_connect_api_btn.disabled = true
	
	@warning_ignore("narrowing_conversion")
	if not await connect_to_hydrus(settings_port_spn_bx.value, settings_key_ln_edt.text):
		settings_request_api_btn.disabled = false
		settings_connect_api_btn.disabled = false


func parse_hydrus_headers(headers_array: Array) -> Dictionary:
	var _headers: Dictionary = {}
	for item in headers_array:
		var elements = item.split(":")
		_headers[elements[0].strip_edges().to_lower()] = elements[1].strip_edges()
	return _headers


func connect_to_hydrus(port: int, key: String) -> bool:
	var access_string: String = LOCAL_ADDRESS.format([port]) + "verify_access_key"
	hydrus_requester.request(access_string, get_hydrus_headers(key))
	
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
	var request_url: String = LOCAL_ADDRESS.format([str(port)]) + "request_new_permissions?name=TagIt%20-%20Tag%20List%20Assistant%26basic_permissions%3D%5B3%5D"
	hydrus_requester.request(request_url)
	SingletonManager.TagIt.log_message(
		"Requesting Hydrus access key.",
		SingletonManager.TagIt.LogLevel.INFO
	)
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
	@warning_ignore("narrowing_conversion")
	
	var access_key: String = await request_hydrus_permissions(settings_port_spn_bx.value)
	
	if not access_key.is_empty():
		settings_key_ln_edt.text = access_key
		#Tagger.queue_notification(
			#"Received access key.
			#Apply permissions on Hydrus then
			#press \"Connect to Hydrus\"",
			#"Key Received")
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
	wiki_gallery.clear_gallery()
	wiki_search_ln_edt.editable = false
	wiki_search_btn.disabled = true
	
	if SingletonManager.TagIt.has_tag(wiki_search) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(wiki_search)):
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
		
		if SingletonManager.TagIt.settings.load_wiki_images and hydrus_connected:
			var files = await search_hydrus_files(
					Array([wiki_search], TYPE_STRING, &"", null),
					SingletonManager.TagIt.settings.wiki_images)
			get_thumbnails(files)
		else:
			wiki_search_ln_edt.editable = true
			wiki_search_btn.disabled = false
		
	else:
		wiki_rtl.clear()
		wiki_title_lbl.text = "[Not Found]"
		wiki_parents_container.visible = false
		wiki_aliases_container.visible = false
		wiki_section_separator.visible = false
		wiki_cat_lbl.text = ""
		wiki_prio_lbl.text = ""



func on_frames_loading_finished() -> void:
	wiki_search_ln_edt.editable = true
	wiki_search_btn.disabled = false


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
	tags_tree.update_tag(tag_id, Array(SingletonManager.TagIt.get_tags_name(tag_data["parents"]).values(), TYPE_STRING, &"", null), tag_data["is_valid"])


func on_website_changed(_ig_a: Variant = null, _ig_b: Variant = null) -> void:
	generate_list_btn.disabled = SingletonManager.TagIt.get_site_count() == 0


func on_group_deleted(group_id: int) -> void:
	SingletonManager.TagIt.remove_tag_group(group_id)


func on_set_group_desc(id: int, prev_desc: String) -> void:
	var new_desc_window = SET_DESC_DIALOG.instantiate()
	add_child(new_desc_window)
	new_desc_window.set_desc(prev_desc)
	new_desc_window.show()
	new_desc_window.focus_first()
	
	var response: Array = await new_desc_window.dialog_finished
	if response[0]:
		SingletonManager.TagIt.set_category_desc(id, response[1])
	
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
		tags_tree.update_category_color(id, response[1])
	
	color_dialog.queue_free()


func add_tag(tag_name: String, clean_suggestions: bool = true) -> void:
	var clean_tag: String = tag_name.strip_edges().to_lower()
	add_tag_ln_edt.clear_no_signal()
	
	if clean_tag.is_empty():
		return
	
	if not Strings.is_invalid_prefix_character(clean_tag.unicode_at(0)):
		var length: int = 0
		for letter_index in range(1, clean_tag.length()):
			length += 1
			if not Strings.is_invalid_prefix_character(clean_tag.unicode_at(letter_index)):
				if SingletonManager.TagIt.has_prefix(clean_tag.substr(0, length)):
					var parts: Array[String] = SingletonManager.TagIt.format_prefix(clean_tag)
					for part in parts:
						add_tag(part)
					return
	
	var tag_id: int = -1
	var icon_id: int = 1
	var icon_color: Color = SingletonManager.TagIt.get_category_icon_color(1)
	var category: int = 1
	var tooltip: String = clean_tag
	
	if SingletonManager.TagIt.has_tag(clean_tag):
		clean_tag = SingletonManager.TagIt.get_alias_name(clean_tag)
		tag_id = SingletonManager.TagIt.get_tag_id(clean_tag)
		
		if SingletonManager.TagIt.has_data(tag_id):
			var tag_data := SingletonManager.TagIt.get_tag_data(tag_id)
			var cat_data := SingletonManager.TagIt.get_category_data(tag_data["category"])
			
			var suggestion_dict := SingletonManager.TagIt.get_tags_name(SingletonManager.TagIt.get_suggestions(tag_id))
			var groups_per_tag := SingletonManager.TagIt.get_groups_and_tags(SingletonManager.TagIt.get_suggested_groups(tag_id))
			
			for group_id in groups_per_tag:
				if not groups_suggestions_tree.has_tag_group(group_id):
					groups_suggestions_tree.add_suggestions(
							groups_per_tag[group_id]["group_name"],
							groups_per_tag[group_id]["tags"],
							group_id)
			
			for suggestion_id in suggestion_dict:
				if not tagger_suggestion_tree.has_suggestion(suggestion_dict[suggestion_id]) and not clean_tag == suggestion_dict[suggestion_id]:
					tagger_suggestion_tree.add_suggestion(suggestion_dict[suggestion_id])
			
			clean_tag = tag_data["tag"]
			category = tag_data["category"]
			icon_id = cat_data["icon_id"]
			icon_color = Color.from_string(cat_data["icon_color"], icon_color)
			tooltip = tag_data["tooltip"]
	
	var target_tree: TreeItem = tags_tree.add_tag(
			tag_id,
			clean_tag,
			tooltip,
			SingletonManager.TagIt.get_icon_texture(icon_id),
			category,
			icon_color)
	
	if tagger_suggestion_tree.has_suggestion(clean_tag) and clean_suggestions:
		tagger_suggestion_tree.delete_tag(clean_tag)
	
	if SingletonManager.TagIt.settings.request_suggestions:
		SingletonManager.eSixAPI.search_suggestions(clean_tag)
	
	if target_tree != null:
		tags_tree.scroll_to_item(target_tree, false)
	
	_list_changed()


func on_esix_api_suggestions_found(for_tag: String, suggestions: Array[String]) -> void:
	if for_tag.is_empty():
		return
	
	if tags_tree.has_tag(for_tag):
		for suggestion in suggestions:
			add_suggestion(suggestion)


func on_create_icon_pressed() -> void:
	var new_icon_select := ICON_SELECTION_DIALOG.instantiate()
	add_child(new_icon_select)
	new_icon_select.show()
	new_icon_select.focus_first()
	var response: Array = await new_icon_select.icon_finished
	if response[0]:
		var icon_id: int = SingletonManager.TagIt.save_icon(response[1], response[2])
		generate_icon_range()
		settings_category_tree.icon_range = icon_range.size() - 1
		settings_category_tree.icon_string = generate_icon_string()
		settings_icons_tree.add_icon(icon_id, response[1], SingletonManager.TagIt.get_icon_texture(icon_id))


func generate_icon_string() -> String:
	var icon_string: String = ""
	for icon_id in icon_range:
		icon_string += SingletonManager.TagIt.get_icon_name(icon_id) #SingletonManager.TagIt.icons[icon_id]["name"]
		if icon_id != icon_range.back():
			icon_string += ","
	return icon_string


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
		var site_id: int = SingletonManager.TagIt.create_site(response[1], response[2], response[3])
		settings_sites_tree.add_site(response[1], site_id)
	new_site_dialog.queue_free()


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


func on_suggestions_activated(suggestions: Array[String], tree: Tree) -> void:
	for suggestion in suggestions:
		add_tag(suggestion)
	tree.delete_tags(suggestions)
	blacklist_tags(suggestions)


func blacklist_tags(tags: Array[String]) -> void:
	Arrays.append_uniques(_suggestion_blacklist, tags)


func generate_icon_range() -> void:
	icon_range.clear()
	for id in SingletonManager.TagIt.icons.keys():
		icon_range.append(int(id))
	
	icon_range.sort()


func on_category_icon_changed(cat_id: int, range_selected: int) -> void:
	SingletonManager.TagIt.set_category_icon(cat_id, icon_range[range_selected])
	tags_tree.update_category_icon(cat_id, SingletonManager.TagIt.get_icon_texture(icon_range[range_selected]))


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
			result[2],
			SingletonManager.TagIt.create_tag_group(result[1], result[2]))
	
	dialog_window.queue_free()


func copy_tags_field() -> void:
	DisplayServer.clipboard_set(tags_label.text)


func export_tags() -> void:
	var export_dialog := FileDialog.new()
	add_child(export_dialog)
	export_dialog.access = FileDialog.ACCESS_FILESYSTEM
	export_dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	export_dialog.use_native_dialog = true
	export_dialog.add_filter("*.txt", "Text File")
	export_dialog.file_selected.connect(on_export_tags_success.bind(export_dialog))
	export_dialog.canceled.connect(on_dialog_cancel_free.bind(export_dialog))
	export_dialog.show()


func on_export_tags_success(path: String, dialog: FileDialog) -> void:
	var tags_file := FileAccess.open(path, FileAccess.WRITE)
	tags_file.store_string(tags_label.text)
	tags_file.close()
	dialog.queue_free()


func on_dialog_cancel_free(dialog: AcceptDialog) -> void:
	dialog.queue_free()


func on_log_created(msg: String) -> void:
	if 201 < settings_logs_txt_edt.get_line_count():
		var first_line: String = settings_logs_txt_edt.get_line(0)
		settings_logs_txt_edt.text = settings_logs_txt_edt.text.substr(first_line.length()).strip_edges(true, false)
	
	if 1000 < msg.length():
		settings_logs_txt_edt.text += msg.substr(0, 1000) + "\n"
	else:
		settings_logs_txt_edt.text += msg + "\n"


func on_select_image_pressed() -> void:
	var image_selector := FileDialog.new()
	add_child(image_selector)
	image_selector.add_filter("*.jpg,*.png,*.wepb", "Images")
	image_selector.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	image_selector.access = FileDialog.ACCESS_FILESYSTEM
	image_selector.use_native_dialog = true
	image_selector.file_selected.connect(on_image_selected.bind(image_selector))
	image_selector.canceled.connect(on_cancelled.bind(image_selector))
	image_selector.show()


func on_image_selected(path: String, dialog: FileDialog) -> void:
	var image := Image.load_from_file(path)
	SingletonManager.TagIt.resize_image(image)
	var texture := ImageTexture.create_from_image(image)
	project_image.texture = texture
	clear_img_btn.disabled = false
	dialog.queue_free()
	_list_changed()


func on_cancelled(dialog: FileDialog) -> void:
	dialog.queue_free()


func on_clear_image_pressed() -> void:
	project_image.texture = null
	clear_img_btn.disabled = true
	_list_changed()


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
	
	if SingletonManager.TagIt.has_tag(clean_name) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(clean_name)):
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


func json_group_to_db(json_result: Dictionary, overwrite: bool = false) -> void:
	var cats_data := SingletonManager.TagIt.get_categories()
	var groups_data := SingletonManager.TagIt.get_tag_groups()
	
	var all_icons: Dictionary = {} # name: -> ID
	var all_cats: Dictionary = {}
	var all_groups: Dictionary = {}
	
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
		all_groups[group_id] = {"name": group_dict["name"], "description": group_dict["description"]}
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
		
		if SingletonManager.TagIt.has_tag(clean_tag) and SingletonManager.TagIt.has_data(SingletonManager.TagIt.get_tag_id(clean_tag)):
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
			for _group_id in groups_data:
				if Strings.nocasecmp_equal(group_text, groups_data[_group_id]["name"]):
					group_suggestions.append(_group_id)
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
