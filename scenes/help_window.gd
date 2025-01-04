extends Control


signal close_pressed

const konami_code = [KEY_UP, KEY_UP, KEY_DOWN, KEY_DOWN, KEY_LEFT, KEY_RIGHT, KEY_LEFT, KEY_RIGHT, KEY_B, KEY_A]
var input_index = 0

@onready var version_label: Label = $MainPanel/DataContainer/LabelsContainer/VersionLabel
@onready var close_button: Button = $MainPanel/DataContainer/LabelsContainer/TitlePanel/CloseButton
@onready var portrait_rect: TextureRect = $MainPanel/DataContainer/PortraitRect


func _ready() -> void:
	version_label.text = TagIt.TAGIT_VERSION
	close_button.pressed.connect(close_pressed.emit)



func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == konami_code[input_index]:
			input_index += 1
			if input_index == konami_code.size():
				portrait_rect.texture = preload("res://textures/ready.png")
				print("alskdjalsWh")
				set_process_input(false)
				input_index = 0
		else:
			input_index = 0 


func is_online_version_higher(local: Array[int], online: Array[int]) -> bool:
	var max_length = max(local.size(), online.size())
	local.resize(max_length)
	online.resize(max_length)
	
	for i in range(max_length):
		if local[i] < online[i]:
			return true # Online is higher
		elif local[i] > online[i]:
			return false # Local is higher
	
	return false # Versions are equal


func check_version() -> void:
	var version_request := HTTPRequest.new()
	add_child(version_request)
	version_request.timeout = 10.0
	var error = version_request.request(
		"https://api.github.com/Ketei/repos/tagit-v3/releases/latest")
	
	var response = await version_request.request_completed
	
	if error == OK and response[0] == OK and response[1] == 200:
		var json_decoder = JSON.new()
		json_decoder.parse(response[3].get_string_from_utf8())
		
		if typeof(json_decoder.data) == TYPE_DICTIONARY:
			if json_decoder.data.has("tag_name"):
				var version_text: String = json_decoder.data["tag_name"].trim_prefix("v")
				var online_version: Array[int] = []
				var local_version: Array[int] = []
				for version_number in version_text.split(".", false):
					if version_number.is_valid_int():
						online_version.append(int(version_number))
				for version_number in TagIt.TAGIT_VERSION.split(".", false):
					local_version.append(int(version_number))
				
				if is_online_version_higher(local_version, online_version):
					pass
				
