extends Control


signal data_selected(data_type: CheckTypes, key_selected: String)
signal data_deselected(data_type: CheckTypes, key_deselected: String)

enum CheckTypes {
	NONE = 0,
	COLOR = 1,
	PATTERNS = 2,
	MARKINGS = 3,
	TATTOOS = 4,
	HORNS = 5,
	SPIKES = 6,
	RIDGES = 7,
	TEETH_TRAITS = 8,
	TONGUE_TRAITS = 9,
	PATTERN_LOCATION = 10,
	NIPPLE_PROP = 11,
	AREOLA_PROP = 12,
	FRILL_LOCATION = 13,
	PENIS_PROPS = 14,
	PENIS_TRAITS = 15,
	ANUS_TRAITS = 16,
	CLAW_LOCATIONS = 17,
	THIGHS_PROPS = 18,
}

const COLORS: Dictionary = {
	"black": Color(0.17, 0.17, 0.17),
	"blue": Color(0.282, 0.467, 0.741),
	"brown": Color(0.549, 0.341, 0.2),
	"green": Color(0.376, 0.714, 0.416),
	"grey": Color(0.55, 0.55, 0.55),
	"orange": Color(0.96, 0.46, 0.217),
	"pink": Color(0.969, 0.573, 0.663),
	"purple": Color(0.502, 0.365, 0.702),
	"red": Color(0.775, 0.234, 0.307),
	"tan": Color(0.946, 0.655, 0.479),
	"teal": Color(0.259, 0.877, 0.674),
	"white": Color(0.85, 0.85, 0.85),
	"yellow": Color(0.994, 0.763, 0.315)}

const PATTERNS: PackedStringArray = [
	"blaze",
	"chevron",
	"circuit",
	"fingerless",
	"flame",
	"floral",
	"gloves",
	"mask",
	"muzzle",
	"ring",
	"rune",
	"socks",
	"spiral",
	"spotted",
	"stockings",
	"striped",
	"toeless",
	"tribal"]

const MARKING: PackedStringArray = [
	"arrow",
	"cogweel",
	"diamond",
	"handprint",
	"heart",
	"mole",
	"moon",
	"musical note",
	"pawprint",
	"radiation symbol",
	"skull",
	"star",
	"sun",
	"tear"]

const TATTOOS: PackedStringArray = [
	"anchor",
	"barcode",
	"butterfly",
	"clover",
	"dragon",
	"gender symbol",
	"heart",
	"pawprint",
	"pentagram",
	"skull",
	"star",
	"sun",
	"tramp stamp",
	"tribal",
	"womb"]

const HORNS: PackedStringArray = [
	"arm",
	"back",
	"cheek",
	"chest",
	"chin",
	"ear",
	"floating",
	"forehead",
	"head",
	"jaw",
	"nose",
	"shoulder"]

const SPIKES: PackedStringArray = [
	"abdomen",
	"arm",
	"back",
	"balls",
	"cheek",
	"chest",
	"chin",
	"ear",
	"head",
	"jaw",
	"nose",
	"penis",
	"shell",
	"shoulder",
	"tail",
	"wing"]

const RIDGE: PackedStringArray = [
	"head",
	"dorsal",
	"tail"]

const TEETH_TRAITS: PackedStringArray = [
	"sharp",
	"tooth gap",
	"buckteeth",
	"sabertooth",
	"tusks",]

const TONGUE_PROPS: PackedStringArray = [
	"barbed",
	"granular",
	"slippery",
	"mellow"]

const PATTERN_LOCATIONS: PackedStringArray = [
	"ankle",
	"anus",
	"arm",
	"back",
	"back of head",
	"ball",
	"belly",
	"breast",
	"butt",
	"cheek",
	"chest",
	"ear",
	"eye",
	"facial",
	"foot",
	"forehead",
	"hand",
	"hip",
	"leg",
	"neck",
	"penis",
	"sheath",
	"shoulder",
	"slit",
	"snout",
	"tail",
	"thigh",
	"vulva",
	"wing",
	"wrist",]

const NIPP_PROPS: PackedStringArray = [
	"erect",
	"glistening",
	"glowing",
	"inverted",
	"mottled",
	"pierced",
	"puffy",
]

const AREOLA_PROPS: PackedStringArray = [
	"glistening",
	"glowing",
	"mottled",
	"pierced",
	"puffy",
]

const FRILL_LOCATION: PackedStringArray = [
	"back",
	"ear",
	"fin",
	"head",
	"neck",
	"tail"
]

const PENIS_PROPS: PackedStringArray = [
	"barbed",
	"nubbed",
	"ribbed",
	"ridged",
	"scaled",
	"spiked",
]

const PENIS_TRAITS: PackedStringArray = [
	"hemipenes",
	"knotted",
	"medial ring",
	"mottled",
	"prehensile",
	"veiny",
	"pierced",
	 
]

const ANUS_TRAITS: PackedStringArray = [
	"at tail base",
	"puffy",
	"detailed",
	"glowing",
	"mottled",
]

const CLAW_LOCATIONS: PackedStringArray = [
	"toe",
	"finger",
	"heel" # claw
]

const THIGH_PROPS: PackedStringArray = [
	"muscular",
	"glistening",
	"veiny",
	"toned"]

@onready var main_container: VBoxContainer = $MainPanel/SmoothScrollContainer/MainContainer
var mode: CheckTypes = CheckTypes.NONE


func _ready() -> void:
	set_process(false)


func _process(_delta: float) -> void:
	if not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		hide_box()
		set_process(false)


func _on_checkbox_toggled(is_on: bool, check_type:CheckTypes, id: String) -> void:
	if is_on:
		data_selected.emit(check_type, id)
	else:
		data_deselected.emit(check_type, id)


func has_items() -> bool:
	return main_container.get_child_count() != 0


func uncheck_boxes() -> void:
	if mode == CheckTypes.COLOR:
		for child in main_container.get_children():
			child.get_child(0).set_pressed_no_signal(false)
	else:
		for child in main_container.get_children():
			child.set_pressed_no_signal(false)


func clear_checkboxes() -> void:
	for check in main_container.get_children():
		check.queue_free()
		main_container.remove_child(check)


func set_mode(check_mode: int) -> void:
	if mode == check_mode:
		return
	$MainPanel/SmoothScrollContainer.scroll_to_top(0.0)
	mode = clampi(check_mode, 0, CheckTypes.size() - 1) as CheckTypes
	
	clear_checkboxes()
	
	match mode:
		CheckTypes.COLOR:
			for color:String in COLORS:
				var new_container: HBoxContainer = HBoxContainer.new()
				var new_check: CheckBox = CheckBox.new()
				var new_color: ColorRect = ColorRect.new()
				
				new_color.custom_minimum_size = Vector2(32.0, 32.0)
				new_check.text = color
				new_check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_color.color = COLORS[color]
				new_check.set_meta(&"item_id", color)
				
				new_container.name = StringName(color) + &"Container"
				new_check.name = &"ColorChkBx"
				new_color.name = &"ColorBox"
				
				new_check.toggled.connect(
						_on_checkbox_toggled.bind(CheckTypes.COLOR, color))
				
				new_container.add_child(new_check)
				new_container.add_child(new_color)
				main_container.add_child(new_container)
		CheckTypes.PATTERNS:
			for pattern:String in PATTERNS:
				var new_pattern: CheckBox = CheckBox.new()
				new_pattern.text = Strings.capitalize(pattern)
				new_pattern.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_pattern.set_meta(&"item_id", pattern)
				new_pattern.name = StringName(pattern) + &"CheckBox"
				new_pattern.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.PATTERNS, pattern)	)
				main_container.add_child(new_pattern)
		CheckTypes.MARKINGS:
			for marking:String in MARKING:
				var new_marking: CheckBox = CheckBox.new()
				new_marking.text = Strings.capitalize(marking)
				new_marking.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_marking.set_meta(&"item_id", marking)
				new_marking.name = StringName(marking) + &"CheckBox"
				new_marking.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.MARKINGS, marking)	)
				main_container.add_child(new_marking)
		CheckTypes.TATTOOS:
			for tattoo:String in TATTOOS:
				var new_tattoo: CheckBox = CheckBox.new()
				new_tattoo.text = Strings.capitalize(tattoo)
				new_tattoo.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_tattoo.set_meta(&"item_id", tattoo)
				new_tattoo.name = StringName(tattoo) + &"CheckBox"
				new_tattoo.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.TATTOOS, tattoo)	)
				main_container.add_child(new_tattoo)
		CheckTypes.HORNS:
			for horn in HORNS:
				var new_horn: CheckBox = CheckBox.new()
				new_horn.text = Strings.capitalize(horn)
				new_horn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_horn.set_meta(&"item_id", horn)
				new_horn.name = StringName(horn) + &"CheckBox"
				new_horn.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.HORNS, horn))
				main_container.add_child(new_horn)
		CheckTypes.SPIKES:
			for spike in SPIKES:
				var new_horn: CheckBox = CheckBox.new()
				new_horn.text = Strings.capitalize(spike)
				new_horn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_horn.set_meta(&"item_id", spike)
				new_horn.name = StringName(spike) + &"CheckBox"
				new_horn.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.SPIKES, spike))
				main_container.add_child(new_horn)
		CheckTypes.RIDGES:
			for ridge in RIDGE:
				var new_horn: CheckBox = CheckBox.new()
				new_horn.text = Strings.capitalize(ridge)
				new_horn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				new_horn.set_meta(&"item_id", ridge)
				new_horn.name = StringName(ridge) + &"CheckBox"
				new_horn.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.RIDGES, ridge))
				main_container.add_child(new_horn)
		CheckTypes.TEETH_TRAITS:
			for item in TEETH_TRAITS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.TEETH_TRAITS, item))
				main_container.add_child(check)
		CheckTypes.TONGUE_TRAITS:
			for item in TONGUE_PROPS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(CheckTypes.TONGUE_TRAITS, item))
				main_container.add_child(check)
		CheckTypes.PATTERN_LOCATION:
			for item in PATTERN_LOCATIONS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.NIPPLE_PROP:
			for item in NIPP_PROPS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.AREOLA_PROP:
			for item in AREOLA_PROPS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.FRILL_LOCATION:
			for item in FRILL_LOCATION:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.PENIS_PROPS:
			for item in PENIS_PROPS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.PENIS_TRAITS:
			for item in PENIS_TRAITS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.ANUS_TRAITS:
			for item in ANUS_TRAITS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.CLAW_LOCATIONS:
			for item in CLAW_LOCATIONS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)
		CheckTypes.THIGHS_PROPS:
			for item in THIGH_PROPS:
				var check: CheckBox = CheckBox.new()
				check.text = Strings.capitalize(item)
				check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				check.set_meta(&"item_id", item)
				check.name = StringName(item) + &"CheckBox"
				check.toggled.connect(
					_on_checkbox_toggled.bind(mode, item))
				main_container.add_child(check)


func set_boxes_checked(ids: Array[String], set_checked: bool) -> void:
	if mode == CheckTypes.COLOR:
		for check in main_container.get_children():
			if ids.has(check.get_child(0).get_meta(&"item_id", "")):
				check.get_child(0).set_pressed_no_signal(set_checked)
	else:
		for check in main_container.get_children():
			if ids.has(check.get_meta(&"item_id", "")):
				check.set_pressed_no_signal(set_checked)


func set_boxes_text(tag: String, prefix: bool) -> void:
	if mode == CheckTypes.COLOR:
		var color: String = ""
		for child in main_container.get_children():
			var chk_bx: CheckBox = child.get_child(0)
			color = chk_bx.get_meta(&"item_id", "black")
			chk_bx.text = str(Strings.capitalize(tag), " ", color) if prefix else str(Strings.capitalize(color), " ", tag)
		await get_tree().process_frame
		size.x = ceil(main_container.size.x / 10.0) * 10


func show_box(at_position: Vector2) -> void:
	position = at_position
	if get_window().size.y < global_position.y + size.y:
		position.y -= (global_position.y + size.y) - get_window().size.y
	if not visible:
		visible = true
		set_process(true)


func hide_box() -> void:
	visible = false
