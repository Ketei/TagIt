extends OptionButton


const GENDERS: PackedStringArray = [
	"Male",
	"Female",
	"Ambiguous",
	"Andromorph",
	"Gynomorph",
	"Hermaphrodite",
	"Male Hermaphrodite"]

const ICONS: Array[Resource] = [
	preload("res://icons/male_icon.svg"),
	preload("res://icons/female_icon.svg"),
	preload("res://icons/ambiguous_gender_icon.svg"),
	preload("res://icons/andro_icon.svg"),
	preload("res://icons/gyno_icon.svg"),
	preload("res://icons/herm_icon.svg"),
	preload("res://icons/male_herm_icon.svg")]

func _ready() -> void:
	clear()
	var id: int = -1
	for item in GENDERS:
		id += 1
		add_icon_item(ICONS[id], item, id)
