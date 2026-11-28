extends PanelContainer


signal window_closed


const ADD_STR: String = "[font_size=20][b][color=SKY_BLUE]New[/color][/b][/font_size]\n[ul]%s[/ul]\n"
const FIX_STR: String = "[font_size=20][b][color=SKY_BLUE]Fixes[/color][/b][/font_size]\n[ul]%s[/ul]"

@onready var close_button: Button = $MainCenter/MainPanel/MainContainer/TitlePanel/TitleContainer/CloseButton
@onready var changes_rt_label: RichTextLabel = $MainCenter/MainPanel/MainContainer/InfoContainer/ChangesRTLabel


const adds: Array[String] = [
	"Projects and templates have new animations. When selecting a project/template, click it again to load it."
]
const fixes: Array[String] = [
	"Fixed templates not loading their respective tags."]


func _ready() -> void:
	var news_str: String = ""
	if not adds.is_empty():
		var news: PackedStringArray = []
		for item in adds:
			news.append(" " + item)
		news_str = ADD_STR % "\n".join(news)
	
	if not fixes.is_empty():
		var news: PackedStringArray = []
		for item in fixes:
			news.append(" " + item)
		news_str += FIX_STR % "\n".join(news)
	
	changes_rt_label.text = news_str
	close_button.pressed.connect(_on_ok_pressed)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"ui_cancel"):
		_on_ok_pressed()
		get_viewport().set_input_as_handled()


func _on_ok_pressed() -> void:
	SingletonManager.TagIt.settings.news_shown = DataManager.TAGIT_VERSION_ARRAY
	window_closed.emit()
	queue_free()
