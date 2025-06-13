class_name AutoSave
extends Resource


const FILE_PATH: String = "user://autosave.tres"

@export var exited_correctly: bool = true
@export var main_list: Array[String] = []
@export var alt_lists: Array[Dictionary] = []
@export var suggestions: Array[String] = []
@export var groups: Array[int] = []
# If it crashed when an UUID is present, it'll reopen the project, replace the
# list data and set the UUID in case the user wants to save.
@export var project_uuid: String = ""


static func get_autosave_file() -> AutoSave:
	var path: String = ProjectSettings.globalize_path(FILE_PATH)
	if FileAccess.file_exists(path):
		var save_res: Resource = load(path)
		if save_res != null and save_res is AutoSave:
			return save_res
	return AutoSave.new()


func safe_exit() -> void:
	exited_correctly = true
	main_list.clear()
	alt_lists.clear()
	suggestions.clear()
	groups.clear()
	ResourceSaver.save(
			self,
			ProjectSettings.globalize_path(FILE_PATH))


func backup_data(main: Array[String], alts: Array[Dictionary], active_suggestions: Array[String], active_groups: Array[int], active_uuid: String = "") -> void:
	main_list = main
	alt_lists = alts
	suggestions = active_suggestions
	groups = active_groups
	project_uuid = active_uuid
	ResourceSaver.save(
			self,
			ProjectSettings.globalize_path(FILE_PATH))
