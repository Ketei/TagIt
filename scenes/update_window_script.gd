extends PanelContainer


signal window_closed

@onready var close_button: Button = $MainCenter/MainPanel/MainContainer/TitlePanel/TitleContainer/CloseButton


func _ready() -> void:
	close_button.pressed.connect(_on_ok_pressed)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		_on_ok_pressed()
		get_viewport().set_input_as_handled()


func _on_ok_pressed() -> void:
	SingletonManager.TagIt.settings.news_shown = DataManager.TAGIT_VERSION_ARRAY
	window_closed.emit()
	queue_free()
