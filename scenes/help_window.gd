extends Control


signal close_pressed

@onready var version_label: Label = $MainPanel/DataContainer/LabelsContainer/VersionLabel
@onready var close_button: Button = $MainPanel/DataContainer/LabelsContainer/TitlePanel/CloseButton


func _ready() -> void:
	version_label.text = TagIt.TAGIT_VERSION
	close_button.pressed.connect(close_pressed.emit)


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
				
