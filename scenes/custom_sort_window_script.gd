extends PanelContainer


signal custom_sort_finished(success: bool, sorting: Array[Dictionary])

enum ItemType {
	ROOT,
	GROUP,
	CATEGORY}

@onready var sorting_tree: Tree = $MainPanel/MainContainer/SortContainer/SortingTree
@onready var categories_tree: Tree = $MainPanel/MainContainer/GroupsContainer/GroupsTree
@onready var reset_sorting_btn: Button = $MainPanel/MainContainer/SortContainer/Label/ResetSortingBtn

@onready var cancel_button: Button = $MainPanel/MainContainer/SortContainer/CancelButton
@onready var save_button: Button = $MainPanel/MainContainer/GroupsContainer/SaveButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var sorting_root: TreeItem = sorting_tree.create_item()
	sorting_root.set_metadata(0, {"type": ItemType.ROOT})
	sorting_root.collapsed = false
	sorting_root.disable_folding = true
	categories_tree.create_item()
	
	sorting_tree.set_column_title(0, "Group")
	sorting_tree.set_column_title(1, "Sorting")
	
	sorting_tree.set_column_expand(0, true)
	sorting_tree.set_column_expand(1, true)
	
	sorting_tree.set_column_expand_ratio(0, 2)
	sorting_tree.set_column_expand_ratio(1, 1)
	
	sorting_root.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	sorting_root.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	
	sorting_root.set_text(0, "Category Sorting")
	
	sorting_root.set_selectable(0, false)
	sorting_root.set_selectable(1, false)
	
	sorting_root.add_button(1, preload("res://icons/group_icon.svg"), 0, false, "Add Group")
	
	var categories := SingletonManager.TagIt.get_categories()
	
	for cat_id in categories:
		var new_cat: TreeItem = categories_tree.create_item()
		new_cat.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
		new_cat.set_text(0, categories[cat_id]["name"])
		new_cat.set_metadata(0, {"type": ItemType.CATEGORY, "id": cat_id})
	
	sorting_tree.button_clicked.connect(_on_button_clicked)
	sorting_tree.category_dropped.connect(_on_category_dropped)
	sorting_tree.item_moved.connect(_on_item_moved)
	reset_sorting_btn.pressed.connect(reset_categories)
	save_button.pressed.connect(_on_save_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_text_delete") and sorting_tree.get_next_selected(null) != null:
		remove_selected_items()
		get_viewport().set_input_as_handled()


func _on_save_pressed() -> void:
	custom_sort_finished.emit(true, get_custom_sorting())


func _on_cancel_pressed() -> void:
	custom_sort_finished.emit(false, Array([], TYPE_DICTIONARY, &"", null))


func _on_item_moved(item: TreeItem, target: TreeItem, at_position: int) -> void:
	match at_position:
		-1:
			item.move_before(target)
		0:
			item.get_parent().remove_child(item)
			target.add_child(item)
		1:
			item.move_after(target)


func _on_category_dropped(on_group: TreeItem, categories: Array[TreeItem], at_position: int) -> void:
	var cat_tree: TreeItem = categories_tree.get_root()
	match at_position:
		-1: # Before
			cat_tree.remove_child(categories[0])
			categories[0].move_before(on_group)
			categories[0].deselect(0)
			categories[0].set_selectable(1, false)
			for cat in range(1, categories.size()):
				categories[cat].move_after(categories[cat - 1])
				categories[cat].deselect(0)
				categories[cat].set_selectable(1, false)
		0: # On
			for cat in categories:
				cat_tree.remove_child(cat)
				on_group.add_child(cat)
				cat.deselect(0)
				cat.set_selectable(1, false)
		1: # After
			cat_tree.remove_child(categories[0])
			categories[0].move_after(on_group)
			categories[0].deselect(0)
			categories[0].set_selectable(1, false)
			for cat in range(1, categories.size()):
				categories[cat].move_after(categories[cat - 1])
				categories[cat].deselect(0)
				categories[cat].set_selectable(1, false)


func create_category(on_tree: TreeItem, category_name: String, category_id: int, at_position: int) -> void:
	var new_cat: TreeItem = null
	
	match at_position:
		-1:
			new_cat = on_tree.get_parent().create_child()
			new_cat.move_before(on_tree)
		0:
			new_cat = on_tree.create_child()
		1:
			new_cat = on_tree.get_parent().create_child()
			new_cat.move_after(on_tree)
		_:
			return
	
	new_cat.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	new_cat.set_cell_mode(1, TreeItem.CELL_MODE_STRING)
	
	new_cat.set_text(0, category_name)
	new_cat.set_metadata(0, {"type": ItemType.CATEGORY, "id": category_id})
	
	new_cat.set_selectable(1, false)


func _on_button_clicked(_item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	if id == 0:
		add_tag_group()


func reset_categories() -> void:
	var tree_target: TreeItem = categories_tree.get_root()
	var cat_groups: Array[TreeItem] = sorting_tree.get_root().get_children()
	
	for cat_group in cat_groups:
		for category in cat_group.get_children():
			cat_group.remove_child(category)
			tree_target.add_child(category)
	
	for cat_group in cat_groups:
		cat_group.free()
	
	var categories: Array[TreeItem] = tree_target.get_children()
	
	categories.sort_custom(_sort_tree_cat_custom)
	
	categories[0].move_before(tree_target.get_first_child())
	
	for category in range(1, categories.size()):
		categories[category].move_after(categories[category - 1])


func move_to_categories_sorted(category_item: TreeItem) -> void:
	var inserted: bool = false
	for cat in categories_tree.get_root().get_children():
		if category_item.get_metadata(0)["id"] < cat.get_metadata(0)["id"]:
			category_item.move_before(cat)
			inserted = true
			break
	if not inserted:
		categories_tree.get_root().add_child(category_item)


func _sort_tree_cat_custom(item_a: TreeItem, item_b: TreeItem) -> bool:
	return item_a.get_metadata(0)["id"] < item_b.get_metadata(0)["id"]


func add_tag_group(group_name: String = "Category Group", sort_mode: int = 0) -> TreeItem:
	var new_group: TreeItem = sorting_tree.get_root().create_child()
	new_group.set_cell_mode(0, TreeItem.CELL_MODE_STRING)
	new_group.set_cell_mode(1, TreeItem.CELL_MODE_RANGE)
	
	new_group.set_text(0, group_name)
	new_group.set_text(1, "Alphabetical,Priority")
	new_group.set_range(1, sort_mode)
	
	new_group.set_editable(0, true)
	new_group.set_editable(1, true)
	new_group.set_metadata(0, {"type": ItemType.GROUP})
	
	return new_group


func set_custom_sorting(sorting_data: Array[Dictionary]) -> void:
	if sorting_data.is_empty():
		return
	
	var categories: Dictionary = SingletonManager.TagIt.get_categories()
	
	for category_data in sorting_data:
		var new_group: TreeItem = add_tag_group(
				category_data["group_name"],
				1 if category_data["sorting"] == DataManager.SortingType.PRIORITY else 0)
		
		var used_ids: Array[int] = []
		
		for category in category_data["group_ids"]:
			if not categories.has(category):
				continue
			used_ids.append(category)
			create_category(
					new_group,
					categories[category]["name"],
					category,
					0)
		
		if not used_ids.is_empty():
			categories_tree.remove_categories(used_ids)


func get_custom_sorting() -> Array[Dictionary]:
	var new_sorting: Array[Dictionary] = []
	
	for group in sorting_tree.get_root().get_children():
		var new_group: Dictionary = {
			"group_name": group.get_text(0),
			"group_ids": Array([], TYPE_INT, &"", null),
			"sorting": DataManager.SortingType.ALPHABETICAL if group.get_range(1) == 0 else DataManager.SortingType.PRIORITY
			}
		for category in group.get_children():
			new_group["group_ids"].append(category.get_metadata(0)["id"])
		new_sorting.append(new_group)
	
	return new_sorting


func remove_selected_items() -> void:
	var next: TreeItem = sorting_tree.get_next_selected(null)
	
	while next != null:
		match next.get_metadata(0)["type"]:
			ItemType.GROUP:
				var target_group: TreeItem = next
				for cat in next.get_children():
					next.remove_child(cat)
					move_to_categories_sorted(cat)
					if cat.is_selected(0):
						cat.deselect(0)
				next = sorting_tree.get_next_selected(next)
				target_group.free()
			
			ItemType.CATEGORY:
				var next_item: TreeItem = sorting_tree.get_next_selected(next)
				next.get_parent().remove_child(next)
				move_to_categories_sorted(next)
				next = next_item
