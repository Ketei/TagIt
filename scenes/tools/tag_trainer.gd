extends TagItTool


signal new_vectors_trained

const CONFIG_PATH: String = "user://trainer_settings.json"
const TVEC_PATH: String = "user://tag_vectors.tvec"
const DIMENSIONS: int = 128

var tag_vectors: Dictionary[String, PackedFloat32Array] = {} # String -> PackedFloat32Array

var possible_prefix_exclude: Dictionary = {
	"character": false,
	"creator": true,
	"lore": true,
	"meta": true,
	"species": true,
	}

var tag_trees: Dictionary[String, TreeItem] = {}
var negative_tags: Dictionary[String, TreeItem] = {}

@onready var background_trainer: HydrusTrainer = $BackgroundTrainer
@onready var sql_db_trainer: SQLiteTrainer = $SQLDBTrainer

@onready var tags_tree: Tree = $VBoxContainer/PanelContainer/TrainerContainer/SettingsContainer/TagsTree
@onready var trainer_tags_ln: LineEdit = $VBoxContainer/PanelContainer/TrainerContainer/SettingsContainer/TrainerTagsLn
@onready var label: Label = $VBoxContainer/PanelContainer/TrainerContainer/SettingsContainer/Label
@onready var ignore_prev_chk: CheckBox = $VBoxContainer/PanelContainer/TrainerContainer/VBoxContainer/VBoxContainer/IgnorePrevChk
@onready var train_button: Button = $VBoxContainer/PanelContainer/TrainerContainer/VBoxContainer/TrainButton
@onready var post_count_spn: SpinBox = $VBoxContainer/PanelContainer/TrainerContainer/VBoxContainer/VBoxContainer/HBoxContainer/PostCountSpn

@onready var training_progress: ProgressBar = $VBoxContainer/PanelContainer/ProgressBar/TrainingProgress
@onready var msg_lbl: Label = $VBoxContainer/PanelContainer/ProgressBar/MsgLbl
@onready var vocab_lbl: Label = $VBoxContainer/PanelContainer/ProgressBar/VocabLbl

@onready var trainer_container: HBoxContainer = $VBoxContainer/PanelContainer/TrainerContainer
@onready var own_database: VBoxContainer = $VBoxContainer/PanelContainer/OwnDatabase


@onready var progress_bar: VBoxContainer = $VBoxContainer/PanelContainer/ProgressBar
@onready var done_btn: Button = $VBoxContainer/PanelContainer/ProgressBar/DoneBtn

@onready var exclude_tag_tree: Tree = $VBoxContainer/PanelContainer/TrainerContainer/ExcludeContainer/ExcludeTagTree
@onready var exclude_tag_ln: LineEdit = $VBoxContainer/PanelContainer/TrainerContainer/ExcludeContainer/ExcludeTagLn
@onready var prefixes_tree: Tree = $VBoxContainer/PanelContainer/TrainerContainer/ExcludeContainer/PrefixesContainer/PrefixesTree
@onready var prefixes_ln: LineEdit = $VBoxContainer/PanelContainer/TrainerContainer/ExcludeContainer/PrefixesContainer/PrefixesLn
@onready var train_selector_opt: OptionButton = $VBoxContainer/TrainSelectorOpt

@onready var db_tag_count: SpinBox = $VBoxContainer/PanelContainer/OwnDatabase/MainContainer/ConfigContainer/DBTagCount
@onready var train_sql_btn: Button = $VBoxContainer/PanelContainer/OwnDatabase/MainContainer/TrainSQLBtn


func _init() -> void:
	tool_id = "trainer"
	tool_description = "Train tag vector maps."
	requires_save = false


func _ready() -> void:
	tags_tree.create_item()
	var pre_root: TreeItem = prefixes_tree.create_item()
	var t: TreeItem = exclude_tag_tree.create_item()
	
	_load_existing_tvec()
	background_trainer.tag_vectors = tag_vectors
	sql_db_trainer.tag_vectors = tag_vectors
	
	if FileAccess.file_exists(CONFIG_PATH):
		var json_string: String = FileAccess.get_file_as_string(CONFIG_PATH)
		var data: Variant = JSON.parse_string(json_string)
		if typeof(data) == TYPE_DICTIONARY:
			if data.has("namespaces") and typeof(data["namespaces"]) == TYPE_DICTIONARY:
				var name_spaces: Dictionary = data["namespaces"]
				possible_prefix_exclude.clear()
				for space in name_spaces:
					if typeof(space) == TYPE_STRING and typeof(name_spaces[space]) == TYPE_BOOL:
						possible_prefix_exclude[space] = name_spaces[space]
		if data.has("tags") and typeof(data["tags"]) == TYPE_ARRAY:
			for item in data["tags"]:
				if typeof(item) == TYPE_STRING:
					var s: String = item
					var clean: String = s.strip_edges().to_lower()
					if clean.is_empty() or tag_trees.has(clean):
						continue
					var new_t: TreeItem = t.create_child()
					new_t.set_text(0, clean)
					tag_trees[clean] = new_t
	
	for item in possible_prefix_exclude:
		var pre: TreeItem = pre_root.create_child()
		pre.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		pre.set_editable(0, true)
		pre.set_text(0, item)
		
		if possible_prefix_exclude[item]:
			pre.set_checked(0, true)
	
	own_database.visible = true
	trainer_container.visible = false
	progress_bar.visible = false
	
	done_btn.pressed.connect(_on_done_button_pressed)
	train_sql_btn.pressed.connect(_on_train_sql_pressed, CONNECT_DEFERRED)
	
	train_button.pressed.connect(_on_train_pressed, CONNECT_DEFERRED)
	trainer_tags_ln.text_submitted.connect(_on_text_submitted)
	exclude_tag_ln.text_submitted.connect(_on_negative_tag_submitted)
	prefixes_ln.text_submitted.connect(_on_prefix_submitted)
	
	train_selector_opt.item_selected.connect(_on_selected_idx_selected)
	
	sql_db_trainer.training_progress.connect(_on_training_progress)
	sql_db_trainer.training_finished.connect(_on_training_finished)
	sql_db_trainer.training_failed.connect(_on_training_failed)
	
	background_trainer.training_progress.connect(_on_training_progress)
	background_trainer.training_finished.connect(_on_training_finished)
	background_trainer.training_failed.connect(_on_training_failed)


func input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.echo or not event.pressed:
			return
		if event.ctrl_pressed or event.shift_pressed:
			return
		
		if event.keycode == KEY_DELETE:
			var target_tree: Tree = null
			var target_dict: Dictionary = {}
			
			if tags_tree.has_focus():
				target_tree = tags_tree
				target_dict = tag_trees
			elif exclude_tag_tree.has_focus():
				target_tree = exclude_tag_tree
				target_dict = negative_tags
			
			if target_tree == null:
				return
			
			var selected: TreeItem = target_tree.get_selected()
			if selected != null:
				target_dict.erase(selected.get_text(0))
				selected.free()
			get_viewport().set_input_as_handled()


func save_training_settings() -> void:
	var tags: Array[String] = []
	tags.assign(negative_tags.keys())
	var json_dict: Dictionary = {
		"namespaces": possible_prefix_exclude,
		"tags": tags}
	
	var file: FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(json_dict))
		file.close()


func _on_selected_idx_selected(idx: int) -> void:
	match idx:
		0:
			trainer_container.visible = false
			own_database.visible = true
		1:
			trainer_container.visible = true
			own_database.visible = false


func _on_done_button_pressed() -> void:
	progress_bar.visible = false
	train_selector_opt.disabled = false
	match train_selector_opt.selected:
		0:
			own_database.visible = true
		1:
			trainer_container.visible = true


func _on_training_progress(current: int, total: int, status_text: String) -> void:
	if training_progress.max_value != total:
		training_progress.max_value = total
	training_progress.value = current
	msg_lbl.text = status_text


func _on_training_finished(trained_post_count: int, total_vocab_size: int) -> void:
	var msg: String = "Training successfull. Trained on %d new post" % trained_post_count
	if trained_post_count != 1:
		msg += "s"
	msg += "."
	
	msg_lbl.text = msg
	vocab_lbl.text = "Vocabulary size: %d" % total_vocab_size
	
	if 0 < trained_post_count:
		new_vectors_trained.emit()
	
	done_btn.disabled = false
	$Node.perform_test()


func _on_training_failed(error_message: String) -> void:
	msg_lbl.text = error_message
	done_btn.disabled = false
	$Node.perform_test()


func _on_train_sql_pressed() -> void:
	var amount: int = int(db_tag_count.value)
	if amount <= 0:
		return
	
	done_btn.disabled = true
	train_selector_opt.disabled = true

	sql_db_trainer.train(amount)
	own_database.visible = false
	progress_bar.visible = true


func _on_train_pressed() -> void:
	if tag_trees.is_empty():
		return
	
	trainer_container.visible = false
	progress_bar.visible = true
	done_btn.disabled = true
	
	training_progress.value = 0
	training_progress.max_value = 0
	msg_lbl.text = ""
	
	var tags: Array[String] = []
	var tag_exclude: Array[String] = []
	var posts: int = int(post_count_spn.value)
	var ignore_previous: bool = ignore_prev_chk.button_pressed
	var prefixes_to_exclude: Array[String] = []
	save_training_settings()
	
	for tag in tag_trees:
		if negative_tags.has(tag):
			continue
		tags.append(tag)
	
	if not negative_tags.is_empty():
		tag_exclude.assign(negative_tags.keys())
	
	for prefix in prefixes_tree.get_root().get_children():
		if prefix.is_checked(0):
			prefixes_to_exclude.append(prefix.get_text(0) + ":")
	
	background_trainer.train_from_hydrus(
			tags,
			posts,
			tag_exclude,
			prefixes_to_exclude,
			ignore_previous)


func _on_text_submitted(text: String) -> void:
	var clean_tag: String = text.strip_edges().to_lower()
	trainer_tags_ln.clear()
	if tag_trees.has(clean_tag) or clean_tag.is_empty():
		return
	
	if SingletonManager.TagIt.has_tag(clean_tag):
		var tag_id: int = SingletonManager.TagIt.get_tag_id(clean_tag)
		if SingletonManager.TagIt.has_data(tag_id):
			var cat: int = SingletonManager.TagIt.get_tag_data_column(
					tag_id,
					"category_id")
			var prefix: String = SingletonManager.TagIt.get_hydrus_category_prefix(
				cat)
			if not prefix.is_empty():
				clean_tag = prefix + ":" + clean_tag
	
	var root: TreeItem = tags_tree.get_root()
	var new_tag: TreeItem = root.create_child()
	new_tag.set_text(0, clean_tag)
	tag_trees[clean_tag] = new_tag


func _on_negative_tag_submitted(text: String) -> void:
	var clean_tag: String = text.strip_edges().to_lower()
	exclude_tag_ln.clear()
	
	if clean_tag.begins_with("-"):
		clean_tag = clean_tag.lstrip("-")
	if clean_tag.is_empty() or negative_tags.has(clean_tag):
		return
	
	var root: TreeItem = exclude_tag_tree.get_root()
	var new_tag: TreeItem = root.create_child()
	new_tag.set_text(0, clean_tag)
	negative_tags[clean_tag] = new_tag


func _on_prefix_submitted(text: String) -> void:
	var clean: String = text.strip_edges().to_lower()
	prefixes_ln.clear()
	
	if clean.ends_with(":"):
		clean.trim_suffix(":")
	
	if clean.is_empty() or possible_prefix_exclude.has(clean):
		return
	
	var root: TreeItem = prefixes_tree.get_root()
	var new_item: TreeItem = root.create_child()
	new_item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	new_item.set_text(0, clean)
	new_item.set_editable(0, true)
	new_item.set_checked(0, true)
	possible_prefix_exclude[clean] = true


func _load_existing_tvec() -> void:
	if not FileAccess.file_exists(TVEC_PATH):
		return
	var file := FileAccess.open(TVEC_PATH, FileAccess.READ)
	if file == null:
		return
	
	var magic: String = file.get_buffer(4).get_string_from_ascii()
	if magic != "TVEC":
		return
	
	var _version: int = file.get_32()
	var dims: int = file.get_32()
	var count: int = file.get_32()
	if dims != DIMENSIONS:
		return
	
	var loaded_tags: Array[String] = []
	for i: int in range(count):
		var str_len: int = file.get_16()
		loaded_tags.append(file.get_buffer(str_len).get_string_from_utf8())
	
	var byte_size: int = DIMENSIONS * 4
	for i: int in range(count):
		var float_vec: PackedFloat32Array = file.get_buffer(byte_size).to_float32_array()
		tag_vectors[loaded_tags[i]] = float_vec
	
	file.close()
