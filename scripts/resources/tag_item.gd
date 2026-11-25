class_name TagItem
extends RefCounted


static var _id_to_tag: Dictionary[int, TagItem] = {}
static var _string_to_tag: Dictionary[String, TagItem] = {}


var tag_id: int = 0
var tag_text: String = ""


static func new_tag(id: int, text: String) -> TagItem:
	var item: TagItem = null
	
	if 0 < id and _id_to_tag.has(id):
		item = _id_to_tag[id]
	elif _string_to_tag.has(text):
		item = _string_to_tag[text]
	else:
		item = TagItem.new(id, text)
		if 0 < id:
			_id_to_tag[id] = item
		_string_to_tag[text] = item
	
	return item


static func set_tag_id(text: String, id: int) -> void:
	if _id_to_tag.has(id) or not _string_to_tag.has(text):
		return
	
	var obj: TagItem = _string_to_tag[text]
	obj.tag_id = id
	_id_to_tag[id] = obj


static func update_tag_name(id: int, text: String) -> void:
	if _id_to_tag.has(id):
		_id_to_tag[id].tag_text = text


func _init(id: int = 0, text: String = "") -> void:
	tag_id = id
	tag_text = text
