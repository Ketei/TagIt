extends VBoxContainer


var results: Array[int] = []
var categories: Dictionary = {}
var groups: Dictionary = {}

@onready var all_tags_tree: Tree = $AllTagsTree
@onready var current_page_spn_bx: SpinBox = $MenuContainer/ButtonButtons/PageContainer/CurrentPageSpnBx
@onready var pages_label: Label = $MenuContainer/ButtonButtons/PageContainer/PagesLabel
@onready var prev_page: Button = $MenuContainer/ButtonButtons/PageContainer/PrevPage
@onready var next_page: Button = $MenuContainer/ButtonButtons/PageContainer/NextPage


func _ready() -> void:
	set_prev_arrow_disabled(true)
	set_next_arrow_disabled(true)
	current_page_spn_bx.value_changed.connect(on_value_changed)
	
	categories = TagIt.get_categories()
	groups = TagIt.get_tag_groups()
	
	next_page.pressed.connect(on_arrow_button_pressed.bind(1))
	prev_page.pressed.connect(on_arrow_button_pressed.bind(-1))
	TagIt.category_created.connect(on_categories_changed)
	TagIt.category_deleted.connect(on_categories_changed)
	TagIt.group_created.connect(on_groups_changed)
	TagIt.group_deleted.connect(on_groups_changed)
	TagIt.category_color_updated.connect(on_category_color_changed)
	TagIt.category_icon_updated.connect(on_category_icon_changed)


func set_prev_arrow_disabled(disabled: bool) -> void:
	prev_page.disabled = disabled
	prev_page.focus_mode = Control.FOCUS_NONE if disabled else Control.FOCUS_ALL


func set_next_arrow_disabled(disabled: bool) -> void:
	next_page.disabled = disabled
	next_page.focus_mode = Control.FOCUS_NONE if disabled else Control.FOCUS_ALL


func on_arrow_button_pressed(val_change: int) -> void:
	current_page_spn_bx.value += val_change


func add_tag_to_table(id: int, tag_name: String, category: int, priority: int, group: int, valid: bool) -> void:
	all_tags_tree.add_tag(id, tag_name, category, categories[category]["name"], priority, group, groups[group]["name"] if 0 < group else "", categories[category]["icon_id"], Color.from_string(categories[category]["icon_color"], Color.WHITE), valid)


func update_table_tag(tag_id: int, tag_name: String, tag_category: String, category_id: int, tag_priority: String, tag_group: String, group_id: int, valid: bool) -> void:
	if all_tags_tree.get_root().get_child_count() == 0:
		return
	all_tags_tree.update_tag(
			tag_id,
			tag_name,
			tag_category,
			category_id,
			TagIt.get_icon_texture(categories[category_id]["icon_id"]),
			Color.from_string(categories[category_id]["icon_color"], Color.WHITE),
			tag_priority,
			tag_group,
			group_id,
			valid)


func on_categories_changed(_id: Variant = null) -> void:
	categories = TagIt.get_categories()


func on_groups_changed(_id: Variant = null, _name: Variant = null) -> void:
	groups = TagIt.get_tag_groups()


func on_category_color_changed(id: int, color: String) -> void:
	if not categories.is_empty():
		categories[id]["icon_color"] = color


func on_category_icon_changed(id: int, icon: int) -> void:
	if not categories.is_empty():
		categories[id]["icon_id"] = icon


func set_search_results(result_array: Array[int]) -> void:
	if result_array.is_empty():
		categories.clear()
		groups.clear()
		all_tags_tree.clear_tags()
		current_page_spn_bx.set_value_no_signal(1)
		current_page_spn_bx.max_value = 1.0
		pages_label.text = "/ 1"
		return
	
	all_tags_tree.clear_tags()
	
	results = result_array
	
	current_page_spn_bx.max_value = ceilf(result_array.size() / float(TagIt.settings.results_per_search)) if not result_array.is_empty() else 1.0
	pages_label.text = "/ " + str(current_page_spn_bx.max_value)
	current_page_spn_bx.set_value_no_signal(1)
	on_value_changed(1)


func on_value_changed(new_value: float) -> void:
	var page: int = int(new_value)
	
	all_tags_tree.clear_tags()
	
	set_prev_arrow_disabled(new_value == 1)
	set_next_arrow_disabled(current_page_spn_bx.max_value <= new_value)
	
	var display_results: Array[int] = results.slice(
			(page - 1) * TagIt.settings.results_per_search,
			TagIt.settings.results_per_search * page)
	
	var tags_data: Dictionary = TagIt.get_tags_data(display_results)
	
	for id_tag in tags_data:
		all_tags_tree.add_tag(
				id_tag,
				tags_data[id_tag]["tag"],
				tags_data[id_tag]["category"],
				categories[tags_data[id_tag]["category"]]["name"],
				tags_data[id_tag]["priority"],
				tags_data[id_tag]["group"],
				groups[tags_data[id_tag]["group"]]["name"] if 0 < tags_data[id_tag]["group"] else "",
				categories[tags_data[id_tag]["category"]]["icon_id"],
				categories[tags_data[id_tag]["category"]]["icon_color"],
				tags_data[id_tag]["is_valid"])
