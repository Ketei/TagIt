extends AcceptDialog

@onready var update_message: RichTextLabel = $UpdateMessage


func set_update_version(version: String) -> void:
	update_message.text = "[center][color=ffc800][url=https://github.com/Ketei/tagit-v3/releases/latest]A new update is available.
v{0}[/url][/color][/center]".format([version])
