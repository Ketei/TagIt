extends FileDialog

signal dialog_finished(success: bool, path: String)
var _filters: Dictionary[String, PackedStringArray] = {}


func _ready() -> void:
	_rebuild_filters()
	
	file_selected.connect(_on_path_selected)
	dir_selected.connect(_on_path_selected)
	canceled.connect(_on_canceled)


# Best executed before ready. Prevents filter rebuilding
func add_filter_extension(type: String, filter: String) -> void:
	var clean_string: String = filter.strip_edges().lstrip(".").to_lower()
	if not clean_string.is_valid_filename() or clean_string.contains("."):
		return
	
	if not _filters.has(type):
		_filters[type] = PackedStringArray()
	var target: PackedStringArray = _filters[type]
	
	var target_index: int = target.bsearch(clean_string)
	var target_size: int = target.size()
	if 0 <= target_index and target_index < target_size:
		if target[target_index] == clean_string:
			return
	
	if target_index == 0:
		if target.is_empty():
			target.append(clean_string)
		else:
			target.insert(0, clean_string)
	elif target_index == target.size():
		target.append(clean_string)
	else:
		target.insert(target_index, clean_string)
	
	if is_node_ready():
		_rebuild_filters()


func _on_path_selected(path: String) -> void:
	dialog_finished.emit(true, path)


func _on_canceled() -> void:
	dialog_finished.emit(false, "")


func _rebuild_filters() -> void:
	clear_filters()
	for extension_desc: String in _filters:
		var extensions: PackedStringArray = []
		for extension: String in _filters[extension_desc]:
			extensions.append("*." + extension)
		var filter_string: String = ",".join(extensions)
		add_filter(filter_string, extension_desc)
