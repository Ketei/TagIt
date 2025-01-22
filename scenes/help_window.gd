extends Control


signal close_pressed

const konami_code = [KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, KEY_B, KEY_A]
var input_index = 0

@onready var version_label: Label = $MainPanel/DataContainer/LabelsContainer/VersionLabel
@onready var close_button: Button = $MainPanel/DataContainer/LabelsContainer/TitlePanel/CloseButton
@onready var portrait_rect: TextureRect = $MainPanel/DataContainer/PortraitRect

@onready var registered_lbl: Label = $MainPanel/DataContainer/LabelsContainer/VBoxContainer/DataContainer/RegisteredLbl
@onready var total_tags_lbl: Label = $MainPanel/DataContainer/LabelsContainer/VBoxContainer/TotalContainer/TotalTagsLbl


func _ready() -> void:
	var stats: Dictionary = SingletonManager.TagIt.get_database_stats()
	registered_lbl.text = Strings.beautify_int(stats["data_count"])#str(stats["data_count"])
	total_tags_lbl.text = Strings.beautify_int(stats["tag_count"])
	
	get_viewport().gui_release_focus()
	version_label.text = DataManager.TAGIT_VERSION
	close_button.pressed.connect(close_pressed.emit)
	



func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == konami_code[input_index]:
			input_index += 1
			if input_index == konami_code.size():
				portrait_rect.texture = preload("res://textures/ready.png")
				set_process_input(false)
				input_index = 0
		else:
			input_index = 0 
