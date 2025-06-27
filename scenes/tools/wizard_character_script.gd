extends TagItTool


var current_selected: TreeItem = null:
	set(new_current):
		current_selected = new_current
		var unblocked: bool = current_selected != null
		body_texture_tree.get_root().collapsed = not unblocked
		clothing_tree.get_root().collapsed = not unblocked
		traits_tree.get_root().collapsed = not unblocked
		species_ln_edt.editable = unblocked
		body_opt_btn.disabled = not unblocked
		gender_opt_btn.disabled = not unblocked
		lore_gender_opt.disabled = not unblocked
		age_opt_btn.disabled = not unblocked
		lore_age_opt_btn.disabled = not unblocked
var data_store: TagItStorage = null
var color_node: TreeItem = null

@onready var character_tree: Tree = $MainPanel/MainContainer/CharactersContainer/CharacterTree
@onready var char_label: Label = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/CharacterContainer/CharLabel
@onready var species_ln_edt: LineEdit = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/BodyMainContainer/SpeciesContainer/SpeciesLnEdt

@onready var gender_opt_btn: OptionButton = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/GenderContainer/VisibleGContainer/GenderOptBtn
@onready var lore_gender_opt: OptionButton = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/GenderContainer/LoreGContainer/LoreGenderOpt

@onready var age_opt_btn: OptionButton = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/AgeContainer/VisibleContainer/AgeOptBtn
@onready var lore_age_opt_btn: OptionButton = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/AgeContainer/LoreContainer/LoreAgeOptBtn
@onready var body_opt_btn: OptionButton = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/BodyMainContainer/BodyContainer/BodyOptBtn

@onready var body_texture_tree: Tree = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerA/ColorsContainer/BodyTextureTree
@onready var clothing_tree: Tree = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerB/ClothingContainer/ClothingTree
@onready var traits_tree: Tree = $MainPanel/MainContainer/DataPanel/MainDataContainer/DataContainerB/TraitsContainer/TraitsTree

@onready var new_character_button: Button = $MainPanel/MainContainer/CharactersContainer/HeaderContainer/NewCharacterButton
@onready var wizard_checkboxes: Control = $WizardCheckboxes


func _init() -> void:
	tool_id = "wizard_character"
	tool_description = "Create character presets for the Wizard."
	requires_save = true


func _ready() -> void:
	const ICONS: Array[Resource] = [
		preload("res://icons/male_icon.svg"),
		preload("res://icons/female_icon.svg"),
		preload("res://icons/ambiguous_gender_icon.svg"),
		preload("res://icons/andro_icon.svg"),
		preload("res://icons/gyno_icon.svg"),
		preload("res://icons/herm_icon.svg"),
		preload("res://icons/male_herm_icon.svg")]
	
	character_tree.create_item()
	traits_tree.create_item()
	clothing_tree.create_item()
	body_texture_tree.create_item()
	
	clothing_tree.set_column_title(0, "Apparel Item")
	traits_tree.set_column_title(0, "Visible Body Trait")
	body_texture_tree.set_column_title(0, "Body Part")
	body_texture_tree.set_column_title(1, "Property")
	
	data_store = TagItStorage.get_storage()
	
	for character_index in range(data_store.character_count()):
		add_character(
				data_store.get_character(character_index).character_tag,
				character_index)
	
	lore_gender_opt.add_item("N/A", 0)
	
	var idx: int = 0
	for gender in TagItWizard.GENDERS:
		idx += 1
		gender_opt_btn.add_icon_item(ICONS[idx - 1], gender, idx)
		lore_gender_opt.add_icon_item(ICONS[idx - 1],gender, idx)
	
	idx = 0
	
	lore_age_opt_btn.add_item("N/A", 0)
	
	for age in TagItWizard.AGES:
		idx += 1
		age_opt_btn.add_item(age, idx)
		lore_age_opt_btn.add_item(age, idx)
	
	idx = -1
	
	for body in TagItWizard.BODIES:
		body_opt_btn.add_item(body)
	body_opt_btn.select(0)
	
	for body_trait in TagItWizard.BODY_TRAITS:
		var new_trait: TreeItem = traits_tree.get_root().create_child()
		new_trait.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_trait.set_text(0, body_trait["title"])
		new_trait.set_editable(0, true)
	
	idx = -1
	for bod_name:Dictionary in TagItWizard.BODY_TYPES:
		idx += 1
		var new_bod: TreeItem = body_texture_tree.get_root().create_child()
		new_bod.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		
		new_bod.disable_folding = true
		
		new_bod.set_text(0, bod_name["name"])
		
		new_bod.set_editable(0, true)
		new_bod.set_selectable(1, false)
		
		if bod_name.has("tooltip") and not bod_name["tooltip"].is_empty():
			new_bod.set_tooltip_text(0, bod_name["tooltip"])
		
		if not bod_name.has("use_colors") or bod_name["use_colors"]:
			var color_child: TreeItem = new_bod.create_child()
			color_child.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
			color_child.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			color_child.set_text(0, "Colors")
			color_child.set_text(1, "0 Colors Selected")
			color_child.add_button(
					1,
					preload("res://icons/color_dropper.png"),
					1,
					false,
					"Pick Colors")
			color_child.set_metadata(0, {"index": -1})
			color_child.set_metadata(1, {"selected_ids": Array([], TYPE_STRING, &"", null), "format": bod_name["tag"]})
		
		if bod_name.has("use_checkboxes") and 0 < bod_name["use_checkboxes"]:
			var check_text: String = ""
			match bod_name["use_checkboxes"]:
				2:
					check_text = "Patterns"
				3:
					check_text = "Markings"
				4:
					check_text = "Tattoos"
			var pattern_child: TreeItem = new_bod.create_child()
			pattern_child.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
			pattern_child.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
			pattern_child.set_text(0, check_text)
			pattern_child.set_text(1, "0 " + check_text + " Selected")
			pattern_child.add_button(
					1,
					preload("res://icons/item_list.png"),
					bod_name["use_checkboxes"],
					false,
					"Pick " + check_text)
			pattern_child.set_metadata(0, {"index": bod_name["use_checkboxes"] * -1})
			pattern_child.set_metadata(1, {"selected_ids": Array([], TYPE_STRING, &"", null)})
		
		var prop_idx: int = -1
		if bod_name.has("properties"):
			for property in bod_name["properties"]:
				prop_idx += 1
				var new_prop: TreeItem = new_bod.create_child()
				new_prop.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
				new_prop.set_cell_mode(1, property["mode"])
				
				new_prop.set_editable(1, true)
				
				new_prop.set_text(0, property["name"])
				new_prop.set_metadata(0, {"index": prop_idx, "id": property["id"]})
				
				if property.has("tooltip"):
					var tips: int = property["tooltip"].size()
					if 2 <= tips and not property["tooltip"][1].is_empty():
						new_prop.set_tooltip_text(1, property["tooltip"][1])
					if 1 <= tips and not property["tooltip"][0].is_empty():
						new_prop.set_tooltip_text(0, property["tooltip"][0])
				
				match property["mode"]:
					TreeItem.CELL_MODE_RANGE:
						if property.has("text") and not property["text"].is_empty():
							new_prop.set_text(1, property["text"])
							new_prop.set_range(
									1,
									property["value"] if property.has("value") else 0)
						else:
							new_prop.set_range_config(
									1,
									property["range"][0],
									property["range"][1],
									1.0)
							new_prop.set_range(
									1,
									property["value"])
					
					TreeItem.CELL_MODE_CHECK:
						new_prop.set_text(1, property["text"])
						new_prop.set_checked(
							1,
							property["value"] if property.has("value") else false)
		
		new_bod.set_metadata(
				0,
				{
					"index": idx,
					"tag": bod_name["tag"]})
	
	idx = -1
	for wear_item in TagItWizard.CLOTHING:
		idx += 1
		var clothing_part: TreeItem = clothing_tree.get_root().create_child()
		clothing_part.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		clothing_part.set_text(0, wear_item["section"])
		clothing_part.set_editable(0, true)
		clothing_part.set_metadata(0, idx)
		var sub_idx: int = -1
		for subitem in wear_item["options"]:
			sub_idx += 1
			var new_sub: TreeItem = clothing_part.create_child()
			new_sub.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
			new_sub.set_editable(0, true)
			new_sub.set_text(0, subitem)
			new_sub.set_metadata(0, sub_idx)
		clothing_part.collapsed = true
		clothing_part.disable_folding = true
	
	gender_opt_btn.select(0)
	lore_gender_opt.select(0)
	age_opt_btn.select(4)
	lore_age_opt_btn.select(0)
	
	body_texture_tree.get_root().collapsed = true
	clothing_tree.get_root().collapsed = true
	traits_tree.get_root().collapsed = true
	
	clothing_tree.item_edited.connect(_on_clothing_item_edited)
	character_tree.item_selected.connect(_on_item_selected)
	new_character_button.pressed.connect(_on_new_character_pressed)
	gender_opt_btn.item_selected.connect(_on_something_changed)
	lore_gender_opt.item_selected.connect(_on_something_changed)
	age_opt_btn.item_selected.connect(_on_something_changed)
	lore_age_opt_btn.item_selected.connect(_on_something_changed)
	species_ln_edt.text_changed.connect(_on_something_changed)
	body_texture_tree.item_edited.connect(_on_something_changed)
	body_texture_tree.item_edited.connect(_on_body_setting_edited)
	traits_tree.item_edited.connect(_on_something_changed)
	
	body_texture_tree.button_clicked.connect(_on_property_button_clicked)
	wizard_checkboxes.data_selected.connect(_on_data_changed.bind(true))
	wizard_checkboxes.data_deselected.connect(_on_data_changed.bind(false))


func _on_property_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	if 0 < id:
		wizard_checkboxes.set_mode(id)
		wizard_checkboxes.set_boxes_text(item.get_parent().get_text(0).to_lower(), false)
		wizard_checkboxes.uncheck_boxes()
		wizard_checkboxes.set_boxes_checked(item.get_metadata(1)["selected_ids"], true)
		wizard_checkboxes.show_box(get_local_mouse_position() - Vector2(20, 20))
		color_node = item


func _on_data_changed(data_type: int, key_selected: String, select: bool) -> void:
	if color_node == null:
		return
	var items: Array[String] = color_node.get_metadata(1)["selected_ids"]
	if select:
		items.append(key_selected)
	else:
		items.erase(key_selected)
	var type_text: String = ""
	
	match data_type:
		1:
			type_text = "color"
		2:
			type_text = "pattern"
		3:
			type_text = "marking"
		4:
			type_text = "tattoo"
	
	color_node.set_text(1, str(items.size(), " ", type_text, "" if items.size() == 1 else "s", " selected"))



func input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action(&"ui_text_delete") and character_tree.get_selected() != null and not event.is_echo():
			var clear: bool = current_selected == character_tree.get_selected()
			data_store.erase_character(character_tree.get_selected().get_text(0))
			character_tree.get_selected().free()
			if clear:
				clear_fields()
				current_selected = null
			something_changed.emit()
			get_viewport().set_input_as_handled()


func _on_body_setting_edited() -> void:
	var edited: TreeItem = body_texture_tree.get_edited()
	if edited.get_parent() != body_texture_tree.get_root():
		return
	edited.disable_folding = not edited.is_checked(0)
	edited.collapsed = edited.disable_folding


func _on_something_changed(_arg: Variant = null) -> void:
	something_changed.emit()


func _on_new_character_pressed() -> void:
	var popup_thing: ConfirmationDialog = preload("res://scenes/dialogs/unique_line_dialog.tscn").instantiate()
	popup_thing.placeholder_text = "New character tag"
	popup_thing.title = "Create Character..."
	popup_thing.blacklist = get_names()
	add_child(popup_thing)
	popup_thing.show()
	popup_thing.focus_main()
	var new_character: Array = await popup_thing.dialog_confirmed
	if new_character[0]:
		add_character(new_character[1], -1, true)
		_on_something_changed()
	popup_thing.queue_free()


func _on_clothing_item_edited() -> void:
	var item: TreeItem = clothing_tree.get_edited()
	item.disable_folding = not item.is_checked(0)
	if item.disable_folding != item.collapsed:
		item.collapsed = item.disable_folding
	_on_something_changed()


func clear_clothing() -> void:
	for top_clothing in clothing_tree.get_root().get_children():
		top_clothing.call_recursive(&"set_checked", 0, false)
		top_clothing.set_collapsed_recursive(true)


func clear_traits() -> void:
	for trait_item in traits_tree.get_root().get_children():
		trait_item.set_checked(0, false)


func clear_body_settings() -> void:
	for setting in body_texture_tree.get_root().get_children():
		setting.set_checked(0, false)
		for property in setting.get_children():
			if property.get_metadata(0)["index"] < 0:
				var type: String = ""
				match property.get_metadata(0)["index"]:
					-1:
						"colors"
					-2:
						"patterns"
					-3:
						"markings"
					-4:
						"tattoos"
				property.get_metadata(1)["selected_ids"].clear()
				property.set_text(1, "0 " + type + " selected")
			else:
				match property.get_cell_mode(1):
					TreeItem.CELL_MODE_CHECK:
						if TagItWizard.BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]].has("value"):
							property.set_checked(
							1,
							TagItWizard.BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]]["value"])
						else:
							property.set_checked(1, false)
						
					TreeItem.CELL_MODE_RANGE:
						if TagItWizard.BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]].has("value"):
							property.set_range(
								1,
								TagItWizard.BODY_TYPES[setting.get_metadata(0)["index"]]["properties"][property.get_metadata(0)["index"]]["value"])
						else:
							property.set_range(1, 0)
		setting.collapsed = true
		setting.disable_folding = true


func clear_fields() -> void:
	clear_clothing()
	clear_traits()
	clear_body_settings()
	char_label.text = ""
	species_ln_edt.text = ""
	body_opt_btn.select(0)
	gender_opt_btn.select(0)
	lore_gender_opt.select(0)
	age_opt_btn.select(4)
	lore_age_opt_btn.select(0)


func add_character(character_tag: String, character_id: int, select: bool = false) -> void:
	var new_character: TreeItem = character_tree.get_root().create_child()
	new_character.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	new_character.set_text(0, character_tag)
	new_character.set_metadata(0, character_id)
	
	if select:
		new_character.select(0)


func has_character(character_tag: String) -> bool:
	for character in character_tree.get_root().get_children():
		if character.get_text(0) == character_tag:
			return true
	return false


func load_character(index: int) -> void:
	var data: TagItStorage.WizardCharacter = data_store.get_character(index)
	char_label.text = Strings.title_case(data.character_tag)
	species_ln_edt.text = data.species
	body_opt_btn.select(data.body_type)
	gender_opt_btn.select(data.gender)
	lore_gender_opt.select(data.gender_lore)
	age_opt_btn.select(data.age)
	lore_age_opt_btn.select(data.age_lore)
	
	clear_body_settings()
	
	for target in body_texture_tree.get_root().get_children():
		if data.properties.has(target.get_metadata(0)["tag"]):
			var prop_data: Dictionary = data.properties[target.get_metadata(0)["tag"]]
			target.set_checked(0, prop_data["use"])
			if prop_data["use"]:
				target.disable_folding = false
			
			for prop_item in target.get_children():
				if prop_item.get_metadata(0)["index"] < 0:
					for prop_dict in prop_data["properties"]:
						if prop_item.get_metadata(0)["index"] == prop_dict["index"]:
							var items: Array[String] = prop_dict["value"]
							prop_item.set_text(1, str(items.size(), " item " if items.size() == 1 else " items ", "selected"))
							prop_item.get_metadata(1)["selected_ids"].clear()
							prop_item.get_metadata(1)["selected_ids"].assign(items)
							break
				else:
					var id: String = prop_item.get_metadata(0)["id"]
					for prop_dict in prop_data["properties"]:
						if prop_dict["index"] < 0:
							continue
						if prop_dict["id"] == id:
							if prop_dict["mode"] == prop_item.get_cell_mode(1):
								match prop_dict["mode"]:
									TreeItem.CELL_MODE_RANGE:
										prop_item.set_range(1, prop_dict["value"])
									TreeItem.CELL_MODE_CHECK:
										prop_item.set_checked(1, prop_dict["value"])
								break
	
	for trait_enabled in traits_tree.get_root().get_children():
		if data.traits.has(trait_enabled.get_text(0)):
			trait_enabled.set_checked(
					0,
					data.traits[trait_enabled.get_text(0)])
	
	for apparel_item in clothing_tree.get_root().get_children():
		if not data.apparel.has(apparel_item.get_text(0)):
			continue
		apparel_item.set_checked(
				0,
				data.apparel[apparel_item.get_text(0)]["active"])
		for specific in apparel_item.get_children():
			if data.apparel[apparel_item.get_text(0)]["subtypes"].has(specific.get_text(0)):
				specific.set_checked(
						0,
						data.apparel[apparel_item.get_text(0)]["subtypes"][specific.get_text(0)])
		
		apparel_item.disable_folding = not data.apparel[apparel_item.get_text(0)]["active"]
		if not apparel_item.collapsed and not data.apparel[apparel_item.get_text(0)]["active"]:
			apparel_item.collapsed = true


func get_names() -> PackedStringArray:
	var names := PackedStringArray()
	for character in character_tree.get_root().get_children():
		names.append(character.get_text(0))
	return names


func save_character():
	var properties: Dictionary = {}
	
	for prop in body_texture_tree.get_root().get_children():
		var setting: Dictionary = {
			"use": prop.is_checked(0),
			"index": prop.get_metadata(0)["index"],
			"properties": Array([], TYPE_DICTIONARY, &"", null)}
		
		for property_item in prop.get_children():
			var idx: int = property_item.get_metadata(0)["index"]
			var property: Dictionary = {
				"mode": property_item.get_cell_mode(1),
				"index": idx}
			
			if 0 <= idx:
				property["id"] = property_item.get_metadata(0)["id"]
			
				match property_item.get_cell_mode(1):
					TreeItem.CELL_MODE_RANGE:
						property["value"] = property_item.get_range(1)
					TreeItem.CELL_MODE_CHECK:
						property["value"] = property_item.is_checked(1)
			else:
				property["value"] = property_item.get_metadata(1)["selected_ids"].duplicate()
				
				if idx == -1:
					property["format"] = property_item.get_metadata(1)["format"]
			setting["properties"].append(property)
		
		properties[prop.get_metadata(0)["tag"]] = setting
	
	var used_clothings: Dictionary = {}
	
	for clothing in clothing_tree.get_root().get_children():
		used_clothings[clothing.get_text(0)] = {
			"active": clothing.is_checked(0),
			"subtypes": {}}
		
		for subtype in clothing.get_children():
			used_clothings[clothing.get_text(0)]["subtypes"][subtype.get_text(0)] = subtype.is_checked(0)
	
	var body_traits: Dictionary = {}
	
	for body_trait in traits_tree.get_root().get_children():
		body_traits[body_trait.get_text(0)] = body_trait.is_checked(0)
	
	var new_sheet: TagItStorage.WizardCharacter = TagItStorage.get_empty_character()
	new_sheet.character_tag = current_selected.get_text(0)
	new_sheet.body_type = body_opt_btn.selected
	new_sheet.species = species_ln_edt.text.strip_edges().to_lower()
	new_sheet.gender = gender_opt_btn.selected
	new_sheet.gender_lore = lore_gender_opt.selected
	new_sheet.age = age_opt_btn.selected
	new_sheet.age_lore = lore_age_opt_btn.selected
	new_sheet.apparel = used_clothings
	new_sheet.properties = properties
	new_sheet.traits = body_traits
	
	data_store.set_character(new_sheet, current_selected.get_metadata(0))
	
	if current_selected.get_metadata(0) == -1:
		current_selected.set_metadata(0, data_store.character_count() - 1)


func _on_item_selected() -> void:
	if current_selected != null:
		save_character()
	
	current_selected = character_tree.get_selected()
	
	if 0 <= current_selected.get_metadata(0):
		load_character(current_selected.get_metadata(0))
	else:
		clear_fields()
		char_label.text = Strings.title_case(current_selected.get_text(0))


func on_save_pressed() -> void:
	if current_selected != null:
		save_character()
	data_store.save()
