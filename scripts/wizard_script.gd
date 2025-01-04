extends PanelContainer


signal wizard_finished(tags: Array[String])
signal wizard_cancelled

const SINGLE_COLOR_BODY: String = "monotone"
const TWO_COLOR_BODY: String = "two tone"
const THREE_PLUS_COLOR_BODY: String = "multicolored"

const BIN_ICON = preload("res://icons/bin_icon.svg")

var characters: Array[Dictionary] = []
var sections: PackedStringArray = [
	"Image Meta",
	"Image Properties",
	"Image Angles",
	"Character Pairings",
	"Characters"]
var current_character: int = -1
var current_page: int = 0:
	set(new_current):
		current_page = new_current
		previous_button.text = "Return" if current_page == 0 else "Previous"
		next_button.text = "Next" if current_page < 4 else "Finish"
		main_panel.get_child(current_page).visible = true
		current_page_lbl.text = str(current_page + 1)
		title_label.text = sections[current_page]

@onready var title_label: Label = $MainContainer/TitleLabel
@onready var previous_button: Button = $MainContainer/MarginContainer/NavigationContainer/PreviousButton
@onready var current_page_lbl: Label = $MainContainer/MarginContainer/NavigationContainer/Pages/CurrentPage
@onready var all_pages: Label = $MainContainer/MarginContainer/NavigationContainer/Pages/AllPages
@onready var next_button: Button = $MainContainer/MarginContainer/NavigationContainer/NextButton

@onready var main_panel: PanelContainer = $MainContainer/MainPanel

@onready var body_texture_tree: Tree = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/BodyTextureTree
@onready var age_opt_btn: OptionButton = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/AgeGenderContainer/AgeMainContainer/AgeContainer/AgeOptBtn
@onready var lore_age_opt_btn: OptionButton = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/AgeGenderContainer/AgeMainContainer/LoreAgeContainer/LoreAgeOptBtn
@onready var gender_opt_btn: OptionButton = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/AgeGenderContainer/HBoxContainer/GenderContainer/GenderOptBtn
@onready var gender_lore_opt_btn: OptionButton = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/AgeGenderContainer/HBoxContainer/GenderLoreContainer/GenderLoreOptBtn
@onready var body_opt_btn: OptionButton = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/BodyContainer/BodyContainer/BodyOptBtn
@onready var characters_tree: Tree = $MainContainer/MainPanel/Characters/MainContainer/ChracterTree/CharactersTree
@onready var character_tag_ln_edt: LineEdit = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/NameContainer/CharacterTagLnEdt
@onready var species_ln_edt: LineEdit = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/BodyContainer/SpeciesBox/SpeciesLnEdt
@onready var clothing_a: HBoxContainer = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/ClothingContainer/ClothingA
@onready var clothing_b: HBoxContainer = $MainContainer/MainPanel/Characters/MainContainer/CharacterField/ClothingContainer/ClothingB
@onready var new_char_btn: Button = $MainContainer/MainPanel/Characters/MainContainer/ChracterTree/Header/NewCharBtn

@onready var pairing_checkbox_container: VBoxContainer = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/GendersContainer/VBoxContainer2/ScrollContainer/CheckboxContainer

@onready var gender_opt_btn_l: OptionButton = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/GendersContainer/VBoxContainer/HBoxContainer/GenderOptBtnL
@onready var gender_opt_btn_r: OptionButton = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/GendersContainer/VBoxContainer/HBoxContainer/GenderOptBtnR
@onready var add_pairing_btn: Button = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/GendersContainer/VBoxContainer/AddPairingBtn
@onready var clear_pairings_btn: Button = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/GendersContainer/VBoxContainer2/ClearPairingsBtn

@onready var bg_opt_btn: OptionButton = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/BGContainer/BgOptBtn
@onready var bg_type_opt_btn: OptionButton = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/BGTypeContainer/BGTypeOptBtn

@onready var medium_opt_btn: OptionButton = $MainContainer/MainPanel/MetaContainer/MainContainer/MediumContainer/MediumOptBtn
@onready var media_type_opt_btn: OptionButton = $MainContainer/MainPanel/MetaContainer/MainContainer/TypeContainer/MediaTypeOptBtn
@onready var artist_line_edit: LineEdit = $MainContainer/MainPanel/MetaContainer/MainContainer/ArtistContainer/ArtistLineEdit
@onready var year_opt_btn: SpinBox = $MainContainer/MainPanel/MetaContainer/MainContainer/HBoxContainer2/YearOptBtn
@onready var unkown_year_btn: CheckButton = $MainContainer/MainPanel/MetaContainer/MainContainer/HBoxContainer2/UnkownYearBtn
@onready var colored_check_box: CheckBox = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/ColorContainer/ColoredCheckBox
@onready var shaded_sketch_box: CheckBox = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/ColorContainer/ShadedSketchBox
@onready var line_style_opt_btn: OptionButton = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/LineContainer/LineStyleOptBtn
@onready var daytime_opt_btn: OptionButton = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/TimeContainer/DaytimeOptBtn
@onready var location_opt_btn: OptionButton = $MainContainer/MainPanel/ImageContainer/HBoxContainer/VBoxContainer/LocationContainer/LocationOptBtn
@onready var sexing: HBoxContainer = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/MinglingContainer/Sexing
@onready var grouping: HBoxContainer = $MainContainer/MainPanel/PairingsContainer/PairingsContainer/MinglingContainer/Grouping

# --- Images ---
@onready var day: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Day
@onready var night: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Night
@onready var outside: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Outside
@onready var outside_detailed: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Outside/OutsideDetailed
@onready var inside: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Inside
@onready var inside_detailed: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Inside/InsideDetailed
@onready var ball: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Ball
@onready var ball_shadow: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Ball/BallShadow
@onready var ball_shaded: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Ball/BallShaded
@onready var sky_rect: ColorRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Background/SkyRect
@onready var background: TextureRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Background
@onready var solid_rect: ColorRect = $MainContainer/MainPanel/ImageContainer/HBoxContainer/PanelContainer/Background/SolidRect

# ---------------

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	characters_tree.create_item()
	body_texture_tree.create_item()
	
	body_texture_tree.set_column_title(0, "Body Type")
	body_texture_tree.set_column_title(1, "Colours")
	
	body_texture_tree.set_column_expand_ratio(0, 2)
	body_texture_tree.set_column_expand_ratio(1, 3)
	add_tree_bodies()
	add_ages(age_opt_btn)
	add_ages(lore_age_opt_btn, true, 0)
	add_genders(gender_opt_btn)
	add_genders(gender_lore_opt_btn, true)
	add_body_types(body_opt_btn)
	
	current_page_lbl.text = "1"
	all_pages.text = str(main_panel.get_child_count())
	current_page = 0
	
	bg_opt_btn.select(0)
	on_background_type_selected(0)
	
	medium_opt_btn.select(0)
	on_media_type_selected(0)
	
	media_type_opt_btn.get_popup().max_size.y = 200
	
	next_button.pressed.connect(on_next_pressed)
	previous_button.pressed.connect(on_previous_pressed)
	new_char_btn.pressed.connect(create_character)
	characters_tree.item_selected.connect(_on_character_selected)
	character_tag_ln_edt.text_changed.connect(on_character_tag_changed)
	add_pairing_btn.pressed.connect(on_add_pairing_pressed)
	clear_pairings_btn.pressed.connect(clear_pairings)
	bg_opt_btn.item_selected.connect(on_background_type_selected)
	medium_opt_btn.item_selected.connect(on_media_type_selected)
	characters_tree.button_clicked.connect(on_character_button_clicked)
	location_opt_btn.item_selected.connect(on_location_picked)
	daytime_opt_btn.item_selected.connect(on_time_picked)
	colored_check_box.toggled.connect(on_colored_toggled)
	shaded_sketch_box.toggled.connect(on_shaded_toggled)
	bg_type_opt_btn.item_selected.connect(on_bg_type_selected)


func on_shaded_toggled(is_toggled: bool) -> void:
	ball_shadow.visible = is_toggled
	ball_shaded.visible = is_toggled


func on_colored_toggled(is_toggled: bool) -> void:
	if is_toggled:
		day.texture = preload("res://textures/wizard/time_day.png")
		night.texture = preload("res://textures/wizard/time_night.png")
		inside.texture = preload("res://textures/wizard/location_inside.png")
		inside_detailed.texture = preload("res://textures/wizard/location_inside_detailed.png")
		outside.texture = preload("res://textures/wizard/location_outside.png")
		outside_detailed.texture = preload("res://textures/wizard/location_outside_detailed.png")
		ball_shadow.texture = preload("res://textures/wizard/ball_shadow.png")
		ball_shaded.texture = preload("res://textures/wizard/ball_shade.png")
		ball.texture = preload("res://textures/wizard/ball.png")
		solid_rect.color = Color(0.266, 0.259, 0.373)
		
		if bg_opt_btn.selected == 1:
			match bg_type_opt_btn.selected:
				1:
					background.texture = preload("res://textures/wizard/abstract.jpg")
				2:
					background.texture = preload("res://textures/wizard/geometric.png")
				3:
					background.texture = preload("res://textures/wizard/gradient.jpg")
				5:
					background.texture = preload("res://textures/wizard/pattern.jpg")
				6:
					background.texture = preload("res://textures/wizard/textured.jpg")
		
		
		
		
		if daytime_opt_btn.selected == 1:
			if colored_check_box.button_pressed:
				sky_rect.color = Color(0.502, 0.741, 0.855)
			else:
				sky_rect.color = Color(0.682, 0.682, 0.682)
		elif daytime_opt_btn.selected == 2:
			if colored_check_box.button_pressed:
				sky_rect.color = Color(0.322, 0.451, 0.722)
			else:
				sky_rect.color = Color(0.443, 0.443, 0.443)
			
	else:
		day.texture = preload("res://textures/wizard/time_day_bw.png")
		night.texture = preload("res://textures/wizard/time_night_bw.png")
		inside.texture = preload("res://textures/wizard/location_inside_bw.png")
		inside_detailed.texture = preload("res://textures/wizard/location_inside_detailed_bw.png")
		outside.texture = preload("res://textures/wizard/location_outside_bw.png")
		outside_detailed.texture = preload("res://textures/wizard/location_outside_detailed_bw.png")
		ball_shadow.texture = preload("res://textures/wizard/ball_shadow_bw.png")
		ball_shaded.texture = preload("res://textures/wizard/ball_shade_bw.png")
		ball.texture = preload("res://textures/wizard/ball_bw.png")
		solid_rect.color = Color(0.37, 0.37, 0.37)
		if bg_opt_btn.selected == 1:
			match bg_type_opt_btn.selected:
				1:
					background.texture = preload("res://textures/wizard/abstract_bw.jpg")
				2:
					background.texture = preload("res://textures/wizard/geometric_bw.png")
				3:
					background.texture = preload("res://textures/wizard/gradient_bw.jpg")
				5:
					background.texture = preload("res://textures/wizard/pattern_bw.jpg")
				6:
					background.texture = preload("res://textures/wizard/textured_bw.jpg")


func clear_pairings() -> void:
	for category in pairing_checkbox_container.get_children():
		for check in category.get_children():
			if check.button_pressed:
				check.button_pressed = false


func on_add_pairing_pressed() -> void:
	const PAIRINGS: PackedStringArray = ["M", "F", "Amb", "And", "G", "H", "MH"]
	var possibility_a: StringName = StringName(PAIRINGS[gender_opt_btn_l.selected] + PAIRINGS[gender_opt_btn_r.selected])
	var possibility_b: StringName = StringName(PAIRINGS[gender_opt_btn_r.selected] + PAIRINGS[gender_opt_btn_l.selected])
	
	for category in pairing_checkbox_container.get_children():
		for checkbox in category.get_children():
			if checkbox.name == possibility_a or checkbox.name == possibility_b:
				checkbox.button_pressed = true
				return


func on_next_pressed() -> void:
	if current_page < 4:
		current_page += 1
	else:
		wizard_finished.emit(generate_tags())


func on_previous_pressed() -> void:
	if 0 < current_page:
		current_page -= 1
	else:
		wizard_cancelled.emit()


func on_character_tag_changed(new_char: String) -> void:
	if current_character == -1:
		return
	characters_tree.get_root().get_child(current_character).set_text(0, new_char.strip_edges())


func create_character(default_name: String = "New Character") -> void:
	var new_character: TreeItem = characters_tree.get_root().create_child()
	new_character.set_text(0, default_name)
	new_character.add_button(0, BIN_ICON, 0, false, "Delete Character")
	characters.append({
		"name": default_name,
		"body": 0,
		"species": "",
		"gender": 0,
		"lore_gender": 0,
		"age": 4,
		"lore_age": 0,
		"bodies": Array([0, 0, 0, 0, 0, 0, 0], TYPE_INT, &"", null),
		"clothing": 0
	})
	new_character.select(0)


func on_character_button_clicked(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	match id:
		0:
			var remove: int = item.get_index()
			characters.remove_at(remove)
			if current_character == remove:
				current_character = -1
				clear_character()
			elif current_character != -1:
				current_character = characters_tree.get_selected().get_index()
			item.free()


func clear_character() -> void:
	character_tag_ln_edt.clear()
	body_opt_btn.select(0)
	species_ln_edt.clear()
	gender_opt_btn.select(0)
	gender_lore_opt_btn.select(0)
	age_opt_btn.select(4)
	lore_age_opt_btn.select(0)
	
	for item in body_texture_tree.get_root().get_children():
		if item.is_checked(0):
			item.set_checked(0, false)
		item.set_range(1, 0)
	
	for check in clothing_a.get_children():
		if check.button_pressed:
			check.button_pressed = false
	
	for check in clothing_b.get_children():
		if check.button_pressed:
			check.button_pressed = false


func on_bg_type_selected(bg_type: int) -> void:
	sky_rect.visible = bg_type == 0
	solid_rect.visible = bg_type == 4
	
	#if bg_type != 0:
	match bg_type:
		0:
			background.texture = null
		1:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/abstract.jpg")
			else:
				background.texture = preload("res://textures/wizard/abstract_bw.jpg")
		2:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/geometric.png")
			else:
				background.texture = preload("res://textures/wizard/geometric_bw.png")
		3:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/gradient.jpg")
			else:
				background.texture = preload("res://textures/wizard/gradient_bw.jpg")
		4:
			if colored_check_box.button_pressed:
				solid_rect.color = Color(0.443, 0.316, 0.475)
			else:
				solid_rect.color = Color(0.369, 0.369, 0.369)
		5:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/pattern.jpg")
			else:
				background.texture = preload("res://textures/wizard/pattern_bw.jpg")
		6:
			if colored_check_box.button_pressed:
				background.texture = preload("res://textures/wizard/textured.jpg")
			else:
				background.texture = preload("res://textures/wizard/textured_bw.jpg")


func save_character() -> void:
	var checked_clothing: int = 0
	var body_textures: Array[int] = []
	
	for item in body_texture_tree.get_root().get_children():
		var value: int = 0
		
		if item.is_checked(0):
			value += 4
		
		value += int(item.get_range(1))
		
		body_textures.append(value)
	
	
	var clothing_array: Array[Control] = []
	clothing_array.append_array(clothing_a.get_children())
	clothing_array.append_array(clothing_b.get_children())
	var bit: int = -1
	for clothing in clothing_array:
		bit += 1
		if clothing.button_pressed:
			checked_clothing |= 1 << bit
		else:
			checked_clothing &= ~(1 << bit)
	
	characters[current_character] = {
		"name": character_tag_ln_edt.text.strip_edges(),
		"body": body_opt_btn.selected,
		"species": species_ln_edt.text.strip_edges(),
		"gender": gender_opt_btn.selected,
		"lore_gender": gender_lore_opt_btn.selected,
		"age": age_opt_btn.selected,
		"lore_age": lore_age_opt_btn.selected,
		"bodies": body_textures,
		"clothing": checked_clothing}


func _on_character_selected() -> void:
	if current_character != -1:
		save_character()
	
	current_character = characters_tree.get_selected().get_index()
	var dict: Dictionary = characters[current_character]
	character_tag_ln_edt.text = dict["name"]
	body_opt_btn.select(dict["body"])
	species_ln_edt.text = dict["species"]
	gender_opt_btn.select(dict["gender"])
	gender_lore_opt_btn.select(dict["lore_gender"])
	age_opt_btn.select(dict["age"])
	lore_age_opt_btn.select(dict["lore_age"])
	var clothing_array: Array[Control] = []
	clothing_array.append_array(clothing_a.get_children())
	clothing_array.append_array(clothing_b.get_children())
	
	var bit_idx: int = -1
	
	var body_idx: int = -1
	var body_root: TreeItem = body_texture_tree.get_root()
	
	for body_texture in dict["bodies"]:
		body_idx += 1
		
		var target: TreeItem = body_root.get_child(body_idx)
		
		target.set_checked(0, (body_texture & 4) == 4)
		target.set_range(1, body_texture & 3)
	
	for clothing in clothing_array:
		bit_idx += 1
		clothing.button_pressed = dict["clothing"] & 1 << bit_idx


func generate_tags() -> Array[String]:
	if -1 < current_character:
		save_character()
	
	var tags: Array[String] = []
	tags.append(
		artist_line_edit.text.strip_edges() if not artist_line_edit.text.strip_edges().is_empty() else "unknown artist")
	
	tags.append(
		str(int(year_opt_btn.value)) if not unkown_year_btn.button_pressed else "unknown year")
	
	tags.append(medium_opt_btn.get_item_text(medium_opt_btn.selected))
	
	if 0 < media_type_opt_btn.selected:
		tags.append(
			media_type_opt_btn.get_item_text(media_type_opt_btn.selected))
	
	#if colored_check_box.button_pressed:
		#if line_style_opt_btn.selected == 0:
			#tags.append("sketch")
			#tags.append("colored sketch")
	
	if line_style_opt_btn.selected == 0: # Sketch
		tags.append("sketch")
		if colored_check_box.button_pressed:
			tags.append("colored sketch")
	
	elif line_style_opt_btn.selected == 1: # Lineart
		if colored_check_box.button_pressed:
			if not shaded_sketch_box.button_pressed:
				tags.append("flat colors")
		else:
			tags.append("line art")
	elif line_style_opt_btn.selected == 2: # Lineless
		tags.append("lineless")
		if colored_check_box.button_pressed and not shaded_sketch_box.button_pressed:
			tags.append("flat colors")
		
	if shaded_sketch_box.button_pressed:
		tags.append("shaded")
	
	if 0 < bg_opt_btn.selected:
		tags.append(bg_opt_btn.get_item_text(bg_opt_btn.selected))
	
	if 0 < bg_type_opt_btn.selected:
		tags.append(bg_type_opt_btn.get_item_text(bg_type_opt_btn.selected))
	
	if 0 < daytime_opt_btn.selected:
		tags.append(daytime_opt_btn.get_item_text(daytime_opt_btn.selected))
	
	if 0 < location_opt_btn.selected:
		tags.append(location_opt_btn.get_item_text(location_opt_btn.selected))
	
	for angle in $MainContainer/MainPanel/AnglesContainer/AnglesHflow.get_children():
		if angle.is_angle_selected:
			tags.append_array(angle.angle_tags)
	
	for pairing in pairing_checkbox_container.get_children():
		for gender_pairing in pairing.get_children():
			if gender_pairing.button_pressed:
				tags.append(gender_pairing.text.replace(" ", ""))
	
	for sex in sexing.get_children():
		if sex.button_pressed:
			tags.append(sex.text)
	
	for group in grouping.get_children():
		if group.button_pressed:
			tags.append(group.text)
	
	
	match characters.size():
		0:
			tags.append("zero pictured")
		1:
			tags.append("solo")
		2:
			tags.append("duo")
		3:
			tags.append_array(["trio", "group"])
		_:
			tags.append("group")
	
	var clothing_checks: Array[Control] = []
	clothing_checks.append_array(clothing_a.get_children())
	clothing_checks.append_array(clothing_b.get_children())
	const clothing_scores: PackedInt32Array = [150, 50, 150, 10, 10, 10, 10, 0, 0, 10]
	
	for character in characters:
		var character_tags: Array[String] = []
		var clothing_score: int = 0
		
		if character["name"].is_empty():
			character_tags.append("unknown character")
		else:
			character_tags.append(character["name"])
		
		character_tags.append_array(body_opt_btn.get_item_metadata(character["body"]))
	
		if not character["species"].is_empty():
			character_tags.append(character["name"])
		
		character_tags.append(gender_opt_btn.get_item_text(character["gender"]))
		character_tags.append(gender_opt_btn.get_item_metadata(character["gender"]).format([body_opt_btn.get_item_metadata(character["body"])[0]]))
		
		var age: String = age_opt_btn.get_item_metadata(character["age"])
		var age_lore: String = age_opt_btn.get_item_metadata(character["lore_age"])
		
		if not age.is_empty:
			character_tags.append(age)
		if not age_lore.is_empty:
			character_tags.append(age_lore)
		if character["lore_gender"] != 0:
			character_tags.append(
				gender_lore_opt_btn.get_item_text(character["lore_gender"]) + " (lore)")
		
		var only_wear: bool = true
		var last_wear: String = ""
		
		var clothing_idx: int = -1
		for check:CheckBox in clothing_checks:
			clothing_idx += 1
			if character["clothing"] & 1 << clothing_idx:
				clothing_score += clothing_scores[clothing_idx]
				character_tags.append(check.text)
				if only_wear and not last_wear.is_empty():
					only_wear = false
				last_wear = check.text
		
		if only_wear and not last_wear.is_empty():
			character_tags.append(last_wear + " only")
		
		var body_idx: int = -1
		for body in character["bodies"]:
			body_idx += 1
			if (body & 4) == 4: # Body is checked
				var body_tag: String = body_texture_tree.get_root().get_child(body_idx).get_text(0)
				character_tags.append(body_tag)
			
				match body & 3:
					0:
						character_tags.append(str(SINGLE_COLOR_BODY, " ", body_tag))
					1:
						character_tags.append(str(TWO_COLOR_BODY, " ", body_tag))
					2:
						character_tags.append(str(THREE_PLUS_COLOR_BODY, " ", body_tag))
		
		Arrays.append_uniques(tags, character_tags)
	
		if 300 <= clothing_score:
			character_tags.append("fully clothed")
		elif 200 <= clothing_score:
			character_tags.append("mostly clothed")
		elif 0 < clothing_score:
			character_tags.append("mostly nude")
		else:
			character_tags.append("nude")
	
	return tags


func add_tree_bodies() -> void:
	const BODY_TYPES: PackedStringArray = ["Fur", "Scales", "Feathers", "Wool", "Skin", "Body", "Exoskeleton"]
	
	for bod_name in BODY_TYPES:
		var new_bod: TreeItem = body_texture_tree.get_root().create_child()
		new_bod.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		new_bod.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
		
		new_bod.set_text(0, bod_name)
		new_bod.set_text(1, "1 Color,2 Colors,3+ Colors")
		
		new_bod.set_editable(0, true)
		new_bod.set_editable(1, true)


func add_body_types(to: OptionButton, select: int = 0) -> void:
	const BODIES: PackedStringArray = ["Anthro", "Semi-Anthro", "Semi-Feral", "Feral", "Human", "Humanoid", "Taur"]
	const TAGS: Array[Array] = [["anthro"], ["anthro", "semi-anthro"], ["feral", "semi-anthro"], ["feral"], ["human"], ["humanoid"], ["taur"]]
	
	#var idx: int = -1
	for body_idx in range(BODIES.size()):
		to.add_item(BODIES[body_idx])
		to.set_item_metadata(body_idx, TAGS[body_idx])
	
	to.select(select)


func add_ages(to: OptionButton, include_na: bool = false, select: int = 4) -> void:
	const AGES: PackedStringArray = ["Baby", "Toddler", "Child", "Adolescent", "Adult", "Mature", "Elderly"]
	const TAGS: PackedStringArray = ["baby", "toddler", "child", "adolescent", "", "", "elderly"]
	var item_idx: int = -1
	
	if include_na:
		item_idx += 1
		to.add_item("N/A")
		to.set_item_metadata(item_idx, "")
	
	for age_idx in range(AGES.size()):
		item_idx += 1
		to.add_item(AGES[age_idx])
		to.set_item_metadata(item_idx, TAGS[age_idx])
	
	to.select(select)


func add_genders(to: OptionButton, include_na: bool = false, select: int = 0) -> void:
	const GENDERS: PackedStringArray = ["Male", "Female", "Ambiguous Gender", "Andromorph", "Gynomorph", "Hermaphrodite", "Male Hermaphrodite"]
	const ICONS: Array[Resource] = [
		preload("res://icons/male_icon.svg"),
		preload("res://icons/female_icon.svg"),
		preload("res://icons/ambiguous_gender_icon.svg"),
		preload("res://icons/andro_icon.svg"),
		preload("res://icons/gyno_icon.svg"),
		preload("res://icons/herm_icon.svg"),
		preload("res://icons/male_herm_icon.svg")]
	
	const FORMATTING: PackedStringArray = ["male {0}", "female {0}", "ambiguous {0}", "andromorph {0}", "gynomorph {0}", "herm {0}", "male herm {0}"]
	var item_idx: int = -1
	
	if include_na:
		item_idx += 1
		to.add_item("N/A")
		to.set_item_metadata(item_idx, "")
	
	for gender_idx in range(GENDERS.size()):
		item_idx += 1
		to.add_icon_item(ICONS[gender_idx], GENDERS[gender_idx])
		to.set_item_metadata(item_idx, FORMATTING[gender_idx])
	
	to.select(select)


func on_background_type_selected(id: int) -> void:
	match id:
		0:
			bg_type_opt_btn.clear()
			bg_type_opt_btn.add_item("N/A")
		1:
			set_simple_background()
		2:
			set_detailed_background()
	bg_type_opt_btn.select(0)


func set_simple_background() -> void:
	const TYPES: PackedStringArray = [
		"N/A",
		"Abstract",
		"Geometric",
		"Gradient",
		"Monotone",
		"Pattern",
		"Textured"]
	
	bg_type_opt_btn.clear()
	
	for type in TYPES:
		bg_type_opt_btn.add_item(type)
	
	inside_detailed.visible = false
	outside_detailed.visible = false


func set_detailed_background() -> void:
	bg_type_opt_btn.clear()
	bg_type_opt_btn.add_item("N/A")
	inside_detailed.visible = true
	outside_detailed.visible = true


func on_location_picked(idx: int) -> void:
	inside.visible = idx == 1
	outside.visible = idx == 2


func on_time_picked(idx: int) -> void:
	sky_rect.visible = idx == 1 or idx == 2
	day.visible = idx == 1
	night.visible = idx == 2
	
	if idx == 0:
		sky_rect.color = Color(1, 1, 1, 0)
	elif idx == 1:
		if colored_check_box.button_pressed:
			sky_rect.color = Color(0.502, 0.741, 0.855)
		else:
			sky_rect.color = Color(0.682, 0.682, 0.682)
	elif idx == 2:
		if colored_check_box.button_pressed:
			sky_rect.color = Color(0.322, 0.451, 0.722)
		else:
			sky_rect.color = Color(0.443, 0.443, 0.443)


func on_media_type_selected(type: int) -> void:
	const TYPES: Array[Array] = [
		["N/A", "Digital Drawing (Artwork)", "Digital Painting (Artwork)", "Pixel (artwork)", "3D (Artwork)", "Oekaki"],
		["N/A", "Colored Pencil (Artwork)", "Marker (Artwork)", "Crayon (Artwork)", "Pastel (Artwork)", "Painting (Artwork)", "Pen (Artwork)", "Sculpture (Artwork)", "Graphite (Artwork)", "Chalk (Artwork)", "Charcoal (Artwork)"],
		["N/A"],
		["N/A", "2D Animation", "3D Animation", "Pixel Animation"]]
	
	media_type_opt_btn.clear()
	
	for some in TYPES[type]:
		media_type_opt_btn.add_item(some)
	media_type_opt_btn.select(0)
