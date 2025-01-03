extends VBoxContainer


var current_id: int = -1
var initial_parents: Array[int] = []
var initial_aliases: Array[int] = []
var initial_suggestions: Array[int] = []
var initial_groups: Array[int] = []


@onready var add_parent_ln_edt: LineEdit = $MainContainer/InfoContainer/RelatedContainer/ParentsContainer/AddParentLnEdt
@onready var add_sugg_ln_edt: LineEdit = $MainContainer/InfoContainer/RelatedContainer/SuggestionsContainer/AddSuggLnEdt
@onready var tag_title_lbl: Label = $MainContainer/InfoContainer/BasicsContainer/NameContainer/TagTitleLbl
@onready var category_opt_btn: OptionButton = $MainContainer/InfoContainer/BasicsContainer/NameContainer/CategoryPnl/MainContainer/CategoryOptBtn
@onready var priority_spn_bx: SpinBox = $MainContainer/InfoContainer/BasicsContainer/NameContainer/PriorityPanel/MainContainer/PrioritySpnBx
@onready var group_opt_btn: OptionButton = $MainContainer/InfoContainer/BasicsContainer/NameContainer/GroupPanel/MainContainer/GroupOptBtn
@onready var aliases_tree: Tree = $MainContainer/InfoContainer/BasicsContainer/NameContainer/AliasesContainer/AliasesTree
@onready var add_alias_ln_edt: LineEdit = $MainContainer/InfoContainer/BasicsContainer/NameContainer/AliasesContainer/AddAliasLnEdt
@onready var search_group_ln_edt: LineEdit = $MainContainer/InfoContainer/BasicsContainer/GrSuggestionsContainer/SearchGroupLnEdt
@onready var gr_sugg_tree: Tree = $MainContainer/InfoContainer/BasicsContainer/GrSuggestionsContainer/GrSuggTree
@onready var parents: Tree = $MainContainer/InfoContainer/RelatedContainer/ParentsContainer/Parents
@onready var suggestions_tree: Tree = $MainContainer/InfoContainer/RelatedContainer/SuggestionsContainer/SuggestionsTree
@onready var save_tag_btn: Button = $MainContainer/WikiContainer/TitleContainer/SaveTagBtn
@onready var close_editor_btn: Button = $MainContainer/WikiContainer/TitleContainer/CloseEditorBtn
@onready var wiki_txt_edt: TextEdit = $MainContainer/WikiContainer/WikiTxtEdt
@onready var tooltip_ln_edt: LineEdit = $MainContainer/WikiContainer/TooltipLnEdt
@onready var saved_notification: PanelContainer = $MainContainer/WikiContainer/TitleContainer/SaveTagBtn/SavedNotification
@onready var is_valid_chk_bx: CheckBox = $MainContainer/InfoContainer/BasicsContainer/NameContainer/ValidPanel/IsValidChkBx


func _ready() -> void:
	load_tag_groups()
	load_categories()
	saved_notification.visible = false
	save_tag_btn.pressed.connect(on_save_tag_pressed)
	add_alias_ln_edt.text_submitted.connect(on_alias_submitted)
	add_parent_ln_edt.text_submitted.connect(on_parent_submitted)
	add_sugg_ln_edt.text_submitted.connect(on_suggestion_submitted)
	TagIt.category_created.connect(on_category_created)
	TagIt.category_icon_updated.connect(on_icon_updated)
	TagIt.category_deleted.connect(on_category_deleted)
	TagIt.group_created.connect(on_group_created)
	TagIt.group_deleted.connect(on_group_deleted)


func on_save_tag_pressed() -> void:
	var wiki_text: String = wiki_txt_edt.text.strip_edges()
	var text_tooltip: String = tooltip_ln_edt.text.strip_edges()
	@warning_ignore("incompatible_ternary")
	
	TagIt.update_tag(
			current_id,
			{"is_valid": int(is_valid_chk_bx.button_pressed)})
	
	@warning_ignore("incompatible_ternary")
	TagIt.update_tag_data(
		current_id,
		{
			"category_id": category_opt_btn.get_item_id(category_opt_btn.selected),
			"description": wiki_text if not wiki_text.is_empty() else null,
			"tooltip": text_tooltip if not text_tooltip.is_empty() else null,
			"priority": int(priority_spn_bx.value),
			"group_id": group_opt_btn.get_item_id(group_opt_btn.selected) if 0 < group_opt_btn.selected else null})
	
	var remove_parents = initial_parents.duplicate()
	var add_parents: Array[String] = parents.get_new_tags()
	
	var remove_suggestions = initial_suggestions.duplicate()
	var add_suggestions: Array[String] = suggestions_tree.get_new_tags()
	
	var remove_aliases = initial_aliases.duplicate()
	var add_aliases: Array[String] = aliases_tree.get_new_tags()
	
	var add_groups: Array[int] = []
	add_groups.assign(Arrays.difference(initial_groups, gr_sugg_tree.get_checked_groups()))
	var remove_groups: Array[int] = initial_groups.duplicate()
	
	Arrays.substract_array(remove_groups, gr_sugg_tree.get_checked_groups())
	Arrays.substract_array(remove_parents, parents.get_existing_ids())
	Arrays.substract_array(remove_aliases, aliases_tree.get_existing_ids())
	Arrays.substract_array(remove_suggestions, suggestions_tree.get_existing_ids())
	
	if not remove_parents.is_empty():
		TagIt.remove_parents(current_id, remove_parents)
	
	if not add_parents.is_empty():
		TagIt.add_parents(current_id, add_parents)
	
	if not remove_aliases.is_empty():
		TagIt.remove_aliases(remove_aliases)
	
	if not add_aliases.is_empty():
		TagIt.add_aliases(add_aliases, tag_title_lbl.text.to_lower())
	
	if not remove_suggestions.is_empty():
		TagIt.remove_suggestions(current_id, remove_suggestions)
	
	if not add_suggestions.is_empty():
		TagIt.add_suggestions(current_id, add_suggestions)
	
	if not remove_groups.is_empty():
		TagIt.remove_group_suggestions(current_id, remove_groups)
	
	if not add_groups.is_empty():
		TagIt.add_group_suggestions(current_id, add_groups)
	
	saved_notification.visible = true
	save_tag_btn.disabled = true
	
	var tween_slide := get_tree().create_tween()
	
	tween_slide.tween_property(saved_notification, "modulate", Color.TRANSPARENT, 1.5)
	tween_slide.set_parallel()
	tween_slide.tween_property(saved_notification, "position", Vector2(-28, 75), 1.5)
	
	await tween_slide.finished
	
	saved_notification.visible = false
	saved_notification.modulate = Color.WHITE
	saved_notification.position = Vector2(-28, 35)
	save_tag_btn.disabled = false


func on_alias_submitted(alias_text: String) -> void:
	var new_alias: String = alias_text.strip_edges()
	add_alias_ln_edt.clear()
	if new_alias.is_empty() or aliases_tree.has_tag(new_alias):
		return
	
	aliases_tree.add_tag(new_alias)


func on_parent_submitted(parent_text: String) -> void:
	var new_parent: String = parent_text.strip_edges()
	add_parent_ln_edt.clear()
	if new_parent.is_empty() or parents.has_tag(new_parent):
		return
	
	parents.add_tag(new_parent)


func on_suggestion_submitted(suggestion_text: String) -> void:
	var new_sugg: String = suggestion_text.strip_edges()
	add_sugg_ln_edt.clear()
	if new_sugg.is_empty() or suggestions_tree.has_tag(new_sugg):
		return
	
	suggestions_tree.add_tag(new_sugg)


func on_category_created(cat_id: int) -> void:
	var cat_data := TagIt.get_category_data(cat_id)
	category_opt_btn.add_icon_item(
			TagIt.get_icon_texture(cat_data["icon_id"]),
			cat_data["name"],
			cat_id)


func on_category_deleted(category: int) -> void:
	for item in range(category_opt_btn.item_count):
		if category_opt_btn.get_item_id(item) == category:
			category_opt_btn.remove_item(item)
			break


func on_icon_updated(cat_id: int, icon_id: int) -> void:
	for item in range(category_opt_btn.item_count):
		if category_opt_btn.get_item_id(item) == cat_id:
			category_opt_btn.set_item_icon(item, TagIt.get_icon_texture(icon_id))
			break


func load_categories() -> void:
	category_opt_btn.clear()
	var categories := TagIt.get_categories()
	for category in categories:
		category_opt_btn.add_icon_item(
				TagIt.get_icon_texture(categories[category]["icon_id"]),
				categories[category]["name"],
				category)


func load_tag_groups() -> void:
	group_opt_btn.clear()
	gr_sugg_tree.clear_groups()
	group_opt_btn.add_item(" - N/A -", 0)
	
	var tag_groups := TagIt.get_tag_groups()
	
	for group in tag_groups:
		group_opt_btn.add_item(tag_groups[group]["name"], group)
		gr_sugg_tree.add_group(group, tag_groups[group]["name"])


func on_group_created(group_id: int, group_name: String) -> void:
	group_opt_btn.add_item(group_name, group_id)
	gr_sugg_tree.add_group(group_id, group_name)


func on_group_deleted(group_id: int) -> void:
	for idx in range(group_opt_btn.item_count):
		if group_opt_btn.get_item_id(idx) == group_id:
			group_opt_btn.remove_item(idx)
			break
	gr_sugg_tree.remove_group(group_id)


func clear_trees() -> void:
	gr_sugg_tree.reset_groups()
	parents.clear_tags()
	suggestions_tree.clear_tags()
	aliases_tree.clear_tags()


func load_tag(tag_id: int) -> void:
	var tag_data := TagIt.get_tag_data(tag_id)
	current_id = tag_id
	clear_all()
	
	tag_title_lbl.text = Strings.title_case(tag_data["tag"])
	initial_parents = tag_data["parents"]
	initial_aliases = tag_data["aliases"]
	initial_suggestions = tag_data["suggestions"]
	initial_groups = tag_data["suggested_groups"]
	
	#if tag_data["category"] != null and 0 < tag_data["category"]:
	select_category(tag_data["category"])
	
	priority_spn_bx.value = tag_data["priority"]
	
	if tag_data["group"] != null and 0 < tag_data["group"]:
		select_group(tag_data["group"])
	else:
		group_opt_btn.select(0)
	
	var aliases_dict: Dictionary = TagIt.get_tags_name(tag_data["aliases"])
	var suggestions_dict: Dictionary = TagIt.get_tags_name(tag_data["suggestions"])
	var parents_dict: Dictionary = TagIt.get_tags_name(tag_data["parents"])
	
	for alias_id in aliases_dict:
		aliases_tree.add_tag(
				aliases_dict[alias_id],
				alias_id)
	
	for parent_id in parents_dict:
		parents.add_tag(
				parents_dict[parent_id],
				parent_id)
	
	for group_id in tag_data["suggested_groups"]:
		gr_sugg_tree.select_group(group_id, true)
	
	for suggestion_id in suggestions_dict:
		suggestions_tree.add_tag(
				suggestions_dict[suggestion_id],
				suggestion_id)

	wiki_txt_edt.text = tag_data["description"]

	tooltip_ln_edt.text = tag_data["tooltip"]
	is_valid_chk_bx.button_pressed = bool(tag_data["is_valid"])


func select_group(group_id: int) -> void:
	for item in range(group_opt_btn.item_count):
		if group_opt_btn.get_item_id(item) == group_id:
			group_opt_btn.select(item)
			break


func select_category(cat_id: int) -> void:
	for cat in range(category_opt_btn.item_count):
		if category_opt_btn.get_item_id(cat) == cat_id:
			category_opt_btn.select(cat)
			break


func clear_all() -> void:
	clear_trees()
	category_opt_btn.select(category_opt_btn.item_count - 1)
	group_opt_btn.select(group_opt_btn.item_count - 1)
	priority_spn_bx.value = 0
	wiki_txt_edt.clear()
	tooltip_ln_edt.clear()
	add_alias_ln_edt.clear()
	add_parent_ln_edt.clear()
	add_sugg_ln_edt.clear()
	search_group_ln_edt.clear()
	is_valid_chk_bx.button_pressed = false
