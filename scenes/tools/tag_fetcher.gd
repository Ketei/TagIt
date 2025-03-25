extends TagItTool


signal fetch_finished

enum QueueStatus {
	QUEUED,
	DOWNLOADING,
	ERROR,
	FETCHED,
	ON_DATABASE
}

var fetched_tags: Dictionary = {}
var cancel_fetch: bool = false
var fetching: bool = false

@onready var queue_tree: IDTree = $QueueContainer/QueueTree
@onready var add_queue_ln_edt: LineEdit = $QueueContainer/AddQueueLnEdt
@onready var log_label: RichTextLabel = $LogContainer/LogLabel
@onready var fetch_tags_btn: Button = $QueueContainer/FetchContainer/FetchTagsBtn
@onready var cancel_fetch_btn: Button = $QueueContainer/FetchContainer/CancelFetchBtn
@onready var fetch_progress: ProgressBar = $QueueContainer/FetchContainer/FetchProgress
@onready var clear_queue_btn: Button = $QueueContainer/HeaderContainer/ClearQueueBtn



func _init() -> void:
	tool_id = "tag_fetch"
	tool_description = "Fetch tags in bulk from e621"
	requires_save = true


func _ready() -> void:
	queue_tree.create_item()
	
	queue_tree.set_column_title(0, "Tag")
	queue_tree.set_column_title(1, "Status")
	
	queue_tree.set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_CENTER)
	queue_tree.set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	
	add_queue_ln_edt.text_submitted.connect(_on_queue_submitted)
	fetch_tags_btn.pressed.connect(_on_fetch_pressed)
	cancel_fetch_btn.pressed.connect(_on_cancel_fetch_pressed)
	clear_queue_btn.pressed.connect(_on_clear_queue_pressed)


func _input(_event: InputEvent) -> void:
	if queue_tree.has_focus() and Input.is_action_just_pressed(&"ui_text_delete"):
		var selected: TreeItem = queue_tree.get_selected()
		if selected != null:
			selected.free()
			get_viewport().set_input_as_handled()


func _on_clear_queue_pressed() -> void:
	clear_queue_tree()


func _on_queue_submitted(tag: String) -> void:
	var clean_tag: String = tag.strip_edges().to_lower()
	add_queue_ln_edt.clear()
	
	if queue_tree.has_item(queue_tree.get_root(), clean_tag, 0):
		return
	
	if SingletonManager.TagIt.has_tag(clean_tag):
		var tag_id: int = SingletonManager.TagIt.get_tag_id(clean_tag)
		var true_id: int = SingletonManager.TagIt.get_alias(tag_id) if SingletonManager.TagIt.has_alias(tag_id) else tag_id
		var true_tag: String = SingletonManager.TagIt.get_tag_name(true_id)
		
		if SingletonManager.TagIt.has_tag_data(true_tag):
			if tag_id != true_id:
				add_to_queue(clean_tag, QueueStatus.ON_DATABASE, true_tag)
			else:
				add_to_queue(true_tag, QueueStatus.ON_DATABASE)
		else:
			if tag_id != true_id:
				add_to_queue(clean_tag, QueueStatus.QUEUED, true_tag)
			else:
				add_to_queue(true_tag, QueueStatus.QUEUED)
	else:
		add_to_queue(clean_tag, QueueStatus.QUEUED)
	
	something_changed.emit()


func _on_cancel_fetch_pressed() -> void:
	log_label.append_text("Canceling Fetch...\n")
	cancel_fetch = true
	cancel_fetch_btn.disabled = true


func _on_fetch_pressed() -> void:
	log_label.clear()
	fetch_tags_btn.disabled = true
	cancel_fetch_btn.disabled = false
	cancel_fetch = false
	fetch_progress.value = 0
	
	var fetch_items: Array[TreeItem] = []
	for item in queue_tree.get_root().get_children():
		if item.get_metadata(1) != QueueStatus.QUEUED:
			continue
		fetch_items.append(item)
	
	if fetch_items.is_empty():
		log_label.append_text(" - No tags to fetch -\n")
		fetch_tags_btn.disabled = false
		cancel_fetch_btn.disabled = true
		return
	
	disable_save.emit()
	disable_switch.emit()
	
	fetch_progress.max_value = fetch_items.size()
	
	log_label.append_text("Waiting in queue for API use\n")
	var uuid_turn: String = await SingletonManager.eSixAPI.await_queue_turn()
	log_label.append_text("Turn obtained\nUUID: \"" + uuid_turn + "\"\n")
	
	for fetch_item in fetch_items:
		if cancel_fetch:
			log_label.append_text("Fetching canceled\n")
			fetch_progress.value = fetch_progress.max_value
			break
		fetch_item.set_text(1, queue_status_string(QueueStatus.DOWNLOADING))
		fetch_item.set_metadata(1, QueueStatus.DOWNLOADING)
		log_label.append_text("Fetching tag: \"" + fetch_item.get_metadata(0) + "\"\n")
		var data: Dictionary = await SingletonManager.eSixAPI.fetch_tag_data(fetch_item.get_metadata(0))
		
		var aliases: Array = data["aliases"]
		var parents: Array = data["parents"]
		var suggestions: Array = data["suggestions"]
		
		Arrays.clean_tag_array(aliases)
		Arrays.clean_tag_array(parents)
		Arrays.clean_tag_array(suggestions)
		
		Arrays.remove_all(parents, fetch_item.get_metadata(0))
		Arrays.remove_all(aliases, fetch_item.get_metadata(0))
		Arrays.remove_all(suggestions, fetch_item.get_metadata(0))
		
		Arrays.substract_array(suggestions, parents)
		
		data["aliases"] = PackedStringArray(aliases)
		data["parents"] = PackedStringArray(parents)
		data["suggestions"] = PackedStringArray(suggestions)
		
		log_label.append_text("\"" + fetch_item.get_metadata(0) + "\" fetched (Ready to store in DB)\n")
		fetched_tags[fetch_item.get_metadata(0)] = data
		fetch_item.set_text(1, queue_status_string(QueueStatus.FETCHED))
		fetch_item.set_metadata(1, QueueStatus.FETCHED)
		fetch_progress.value += 1
		something_changed.emit()
	
	fetch_tags_btn.disabled = false
	cancel_fetch_btn.disabled = true
	SingletonManager.eSixAPI._queue_turn_resolved()
	fetch_finished.emit()
	enable_save.emit()
	enable_switch.emit()


func clear_queue_tree() -> void:
	for item in queue_tree.get_root().get_children():
		item.free()


func add_to_queue(tag: String, status: QueueStatus, alias: String = "") -> void:
	var new_queue: TreeItem = queue_tree.get_root().create_child()
	if alias.is_empty():
		new_queue.set_text(0, tag)
	else:
		new_queue.set_text(0, str(tag, " → ", alias))
	new_queue.set_text(1, queue_status_string(status))
	if status == QueueStatus.ON_DATABASE:
		new_queue.set_custom_color(1, Color.LIGHT_GREEN)
	
	new_queue.set_text_alignment(1, HORIZONTAL_ALIGNMENT_CENTER)
	
	new_queue.set_metadata(0, tag if alias.is_empty() else alias)
	new_queue.set_metadata(1, status)


func queue_status_string(status: QueueStatus) -> String:
	match status:
		QueueStatus.QUEUED:
			return "Queued"
		QueueStatus.DOWNLOADING:
			return "Downloading"
		QueueStatus.ERROR:
			return "Couldn't Fetch"
		QueueStatus.FETCHED:
			return "Fetched"
		QueueStatus.ON_DATABASE:
			return "On Database"
		_:
			return "Unknown"


func on_save_pressed() -> void:
	for tag:String in fetched_tags:
		SingletonManager.TagIt.create_tag(
				tag,
				1,
				fetched_tags[tag]["wiki"],
				0)
		
		var tag_id: int = SingletonManager.TagIt.get_tag_id(tag)
		SingletonManager.TagIt.add_parents(
				tag_id,
				fetched_tags[tag]["parents"])
		SingletonManager.TagIt.add_suggestions(
				tag_id,
				fetched_tags[tag]["suggestions"])
		
		SingletonManager.TagIt.add_aliases(
				fetched_tags[tag]["aliases"],
				tag)
	
	if not fetched_tags.is_empty():
		for tag_tree in queue_tree.get_root().get_children():
			if tag_tree.get_metadata(1) != QueueStatus.FETCHED:
				continue
			tag_tree.set_text(1, queue_status_string(QueueStatus.ON_DATABASE))
			tag_tree.set_metadata(1, QueueStatus.ON_DATABASE)
			tag_tree.set_custom_color(1, Color.LIGHT_GREEN)
		log_label.append_text("Fetched tags stored in DB\n")
		fetched_tags.clear()
