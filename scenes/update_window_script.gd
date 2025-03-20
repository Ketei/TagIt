extends PanelContainer


@onready var close_button: Button = $MainCenter/MainPanel/MainContainer/TitlePanel/TitleContainer/CloseButton


func _ready() -> void:
	close_button.pressed.connect(_on_ok_pressed)


func _on_ok_pressed() -> void:
	SingletonManager.TagIt.settings.news_shown = DataManager.TAGIT_VERSION_ARRAY
	queue_free()
