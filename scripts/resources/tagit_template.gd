class_name TagItTemplate
extends RefCounted


var _uuid: String = "":
	set(u):
		_uuid = u
		_hash = u.replace("-", "")
var _hash: String = ""
var _thumbnail: ImageTexture = null
var _thumbnail_changed: bool = false

var title: String = ""
var description: String = ""
var groups: Array[int] = []
var tags: Array[String] = []



func get_thumbnail() -> ImageTexture:
	if _thumbnail == null:
		return null
	return _thumbnail.duplicate()


func set_thumbnail(thumb: ImageTexture) -> void:
	_thumbnail = thumb
	_thumbnail_changed = true


func thumbnail_updated() -> bool:
	return _thumbnail_changed


func update_thumbnail(lossy: bool = false, quality: float = 0.75) -> void:
	if not _thumbnail_changed:
		return
	
	if _hash.is_empty():
		return
	
	_thumbnail_changed = false
	
	var thumb_path: String = TemplateResource.get_thumbnail_path(_hash)
	if FileAccess.file_exists(thumb_path):
		OS.move_to_trash(thumb_path)
	
	if _thumbnail == null:
		return
	
	var img: Image = _thumbnail.get_image()
	img.save_webp(thumb_path, lossy, quality)


func overwrite_thumbnail(img: Image, lossy: bool = false, quality: float = 0.75) -> bool:
	if _thumbnail == null and img == null:
		return true
	if _hash.is_empty():
		return false
	
	var thumb_path: String = TemplateResource.get_thumbnail_path(_hash)
	if FileAccess.file_exists(thumb_path):
		OS.move_to_trash(thumb_path)
		_thumbnail = null
	
	if img == null:
		return true
	
	var err: int = img.save_webp(thumb_path, lossy, quality)
	if err == OK:
		_thumbnail = img.duplicate()
		return true
	else:
		return false
