extends ConfirmationDialog


signal site_concluded(is_success: bool, site_name: String, tag_whitespace: String, site_separator: String, use_prefixes: bool)


static var rgx: RegEx

var is_create: bool = true:
	set(c):
		is_create = c
		if c:
			title = "Create Site..."
			ok_button_text = "Create"
		else:
			title = "Update Site..."
			ok_button_text = "Update"

@onready var site_name_ln_edt: LineEdit = $MainContainer/SiteNameLnEdt
@onready var whitespace_ln_edt: LineEdit = $MainContainer/DataContainer/WhitespaceContainer/WhitespaceLnEdt
@onready var separator_ln_edit: LineEdit = $MainContainer/DataContainer/SeparatorContainer/SeparatorLnEdit
@onready var use_prefix_btn: CheckBox = $MainContainer/UsePrefixBtn


static func _static_init() -> void:
	rgx = RegEx.new()
	rgx.compile("\\\\([nt])(?![a-zA-Z0-9_])")


func _ready() -> void:
	confirmed.connect(on_confirmed)
	canceled.connect(on_cancelled)
	separator_ln_edit.focus_next = get_ok_button().get_path()
	get_ok_button().focus_previous = separator_ln_edit.get_path()
	get_cancel_button().focus_next = site_name_ln_edt.get_path()
	site_name_ln_edt.focus_previous = get_cancel_button().get_path()
	
	whitespace_ln_edt.text_changed.connect(on_data_changed)
	separator_ln_edit.text_changed.connect(on_data_changed)
	get_ok_button().disabled = true


func unescape_allowed(text: String) -> String:
	var result: String = text
	var matches: Array[RegExMatch] = rgx.search_all(text)
	
	for i: int in range(matches.size() - 1, -1, -1):
		var match_item: RegExMatch = matches[i]
		var start_pos: int = match_item.get_start()
		var end_pos: int = match_item.get_end()
		var code: String = match_item.get_string(1)
		
		var replacement: String = "\n" if code == "n" else "\t"
		result = result.substr(0, start_pos) + replacement + result.substr(end_pos)
	
	return result


func focus_first() -> void:
	site_name_ln_edt.grab_focus()


func on_data_changed(_text: String) -> void:
	get_ok_button().disabled = whitespace_ln_edt.text.is_empty() or separator_ln_edit.text.is_empty()


func on_confirmed() -> void:
	var whitespace: String = unescape_allowed(whitespace_ln_edt.text)
	var separator: String = unescape_allowed(separator_ln_edit.text)
	
	site_concluded.emit(
			true,
			site_name_ln_edt.text.strip_edges(),
			whitespace,
			separator,
			use_prefix_btn.button_pressed)


func on_cancelled() -> void:
	site_concluded.emit(
			false,
			"",
			"",
			"",
			false)
