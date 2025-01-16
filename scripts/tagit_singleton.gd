class_name DataManager
extends Node


signal message_logged(msg: String)
signal group_created(group_id: int, group_name: String)
signal group_deleted(group_id: int)
signal category_color_updated(cat_id: int, color: String)
signal category_icon_updated(cat_id: int, icon_id: int)
signal category_deleted(cat_id: int)
signal category_created(category_id: int)
signal tag_deleted(tag_id: int)
signal tag_updated(tag_id: int)
signal tag_created(tag_name: String, tag_id: int)
signal tags_validity_updated(tag_ids: Array[int], valid: bool)
signal website_created(site_id: int, site_name: String)
signal website_deleted(site_id: int)

const DATABASE_PATH: String = "user://tag_database.db"
const SEARCH_WILDCARD: String = "*"
const DB_VERSION: int = 1
const TAGIT_VERSION: String = "3.0.0"
const MAX_PARENT_RECURSION: int = 100
const IMAGE_LIMITS: Vector2i = Vector2i(700, 700)
const LEV_DISTANCE: float = 0.75
const LEV_LOOP_LIMIT: int = 100

enum LogLevel {
	INFO,
	WARNING,
	ERROR,
}

var tag_database: SQLite = null
#var projects_database: SQLite = null
#var tag_relations: TagRelationsRes = null
var icons: Dictionary = {} # id: {name: string, texture: resource}
var loaded_tags: Dictionary = {} # Loaded in memory as need quick access. name -> id
var invalid_tags: Array[int] = [] # MIGHT not be needed in memory. Check once working on the tag list
var tag_search_array: PackedStringArray = []
var tag_search_data: PackedStringArray = []
#var current_tags: int = 0
#var data_tags: Array[int] = []
var settings: AppSettingsRes = null
var _default_icon_color: Color = Color.WHITE
var splash_node: CanvasLayer = null


# --- Icons ---

func _load_icon_data(id: int) -> void:
	var icon_data := _get_icon_data(id)
	icons[id]["texture"] = icon_data["texture"]


func _get_icon_data(id: int) -> Dictionary: # Maybe integrate up
	var db_data := tag_database.select_rows("icons", "id = " + str(id), ["*"])
	var icon_image: Image = Image.new()
	
	icon_image.load_webp_from_buffer(db_data[0]["image"])
	
	return {
		"name": db_data[0]["name"],
		"texture": ImageTexture.create_from_image(icon_image)}

# Needs to be run on main tagger load.
func tagit_setup() -> void:
	settings = AppSettingsRes.get_settings()
	
	if not DirAccess.dir_exists_absolute(TemplateResource.TEMPLATE_PATH.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(TemplateResource.TEMPLATE_PATH.get_base_dir())
	if not DirAccess.dir_exists_absolute("user://templates/thumbnails/"):
		DirAccess.make_dir_absolute("user://templates/thumbnails/")
	
	if not DirAccess.dir_exists_absolute(TagItProjectResource.get_resource_path().get_base_dir()):
		DirAccess.make_dir_recursive_absolute(TagItProjectResource.get_resource_path().get_base_dir())
	
	if not DirAccess.dir_exists_absolute(TagItProjectResource.get_thumbnails_path()):
		DirAccess.make_dir_absolute(TagItProjectResource.get_thumbnails_path())
	
	tag_database = SQLite.new()
	tag_database.path = DATABASE_PATH
	tag_database.foreign_keys = true
	
	tag_database.open_db()
	
	# Set pragmas on tag database to improve i/o speed
	tag_database.query("PRAGMA synchronous = NORMAL; PRAGMA journal_mode = WAL; PRAGMA temp_store = MEMORY;")
	
	tag_database.query("SELECT name FROM sqlite_master WHERE type = 'table';")
	
	if tag_database.query_result.is_empty():
		var version_table: Dictionary = {
			"version": {"data_type": "int", "not_null": true},#, "primary_key": true},
			"author": {"data_type": "text"}}
		
		var tags_table: Dictionary = {
			"id": {"data_type": "int", "auto_increment": true, "not_null": true, "primary_key": true, "unique": true},
			"name": {"data_type": "text", "not_null": true},
			"is_valid": {"data_type": "int", "not_null": true, "default": 1}}
		
		var tag_groups: Dictionary = {
			"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true, "unique": true},
			"name": {"data_type": "text"}, 
			"description": {"data_type": "text"}}
		
		var icons_table: Dictionary = {
			"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true, "unique": true},
			"name": {"data_type": "text"},
			"image": {"data_type": "blob"}}
		
		var sites_table: Dictionary = {
			"id": {"data_type": "int", "primary_key": true, "not_null": true, "auto_increment": true, "unique": true},
			"name": {"data_type": "text"},
			"whitespace": {"data_type": "text", "not_null": true},
			"separator": {"data_type": "text", "not_null": true}}
		
		var prefix_table: Dictionary = {
			"prefix": {"data_type": "text", "primary_key": true, "not_null": true, "unique": true},
			"format": {"data_type": "text"}}
		
		tag_database.create_table("tags", tags_table)
		tag_database.create_table("icons", icons_table)
		tag_database.create_table("prefixes", prefix_table)
		tag_database.query( # suggestions
				"CREATE TABLE suggestions ( 
					tag_id INTEGER NOT NULL, 
					suggestion_id INGETER NOT NULL, 
					PRIMARY KEY (tag_id, suggestion_id), 
					FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION, 
					FOREIGN KEY (suggestion_id) REFERENCES tags(id));")
		tag_database.query( # group_suggestions
				"CREATE TABLE group_suggestions (
					tag_id INTEGER NOT NULL PRIMARY KEY,
					group_id INTEGER NOT NULL,
					FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE CASCADE ON UPDATE NO ACTION,
					FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION);")
		tag_database.query( # categories
				"CREATE TABLE categories ( 
					id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, 
					icon_id INTEGER DEFAULT 1,
					name TEXT,
					description TEXT,
					icon_color TEXT,
					FOREIGN KEY (icon_id) REFERENCES icons (id) ON DELETE SET DEFAULT ON UPDATE NO ACTION);")
		tag_database.create_table("groups", tag_groups)
		tag_database.query(
			"CREATE TABLE hydrus_prefixes (
				category_id INTEGER PRIMARY KEY NOT NULL,
				prefix TEXT,
				FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE ON UPDATE NO ACTION);")
		tag_database.query( # aliases
				"CREATE TABLE aliases (
					antecedent INTEGER NOT NULL,
					consequent INTEGER NOT NULL,
					PRIMARY KEY (antecedent, consequent),
					FOREIGN KEY (antecedent) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION,
					FOREIGN KEY (consequent) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION);")
		tag_database.query( # data
				"CREATE TABLE data ( 
					id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, 
					tag_id INTEGER NOT NULL, 
					category_id INTEGER NOT NULL DEFAULT 1, 
					group_id INTEGER,
					description TEXT,
					tooltip TEXT,
					priority INTEGER NOT NULL DEFAULT 0,
					FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION,
					FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET DEFAULT ON UPDATE NO ACTION,
					FOREIGN KEY (group_id) REFERENCES groups (id) ON DELETE SET NULL ON UPDATE NO ACTION);")
		tag_database.create_table("_version", version_table)
		tag_database.insert_row("_version", {"version": DB_VERSION, "author": "Ketei"})
		tag_database.query( # relationships
				"CREATE TABLE relationships ( 
				parent INTEGER NOT NULL, 
				child INTEGER NOT NULL, 
				PRIMARY KEY (parent, child), 
				FOREIGN KEY (parent) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION, 
				FOREIGN KEY (child) REFERENCES tags (id) ON DELETE CASCADE ON UPDATE NO ACTION);")
		tag_database.create_table("sites", sites_table)
		
		tag_database.insert_rows(
				"icons",
				[
					{
						"id": 1,
						"name": "generic",
						"image": preload("res://icons/icon_tag_generic.svg").get_image().save_webp_to_buffer()
					}
				])
		
		tag_database.insert_row(
				"categories",
				{
					"id": 1,
					"icon_id": 1,
					"name": "Generic",
					"description": "A category for tags that lacks specificity.",
					"icon_color": "ffffff"})
	else:
		# Clean up tags that are not found in any of the reference tables.
		tag_database.query(
			"DELETE FROM tags WHERE id NOT IN (
				SELECT tag_id FROM data
				UNION
				SELECT parent FROM relationships
				UNION
				SELECT child FROM relationships
				UNION
				SELECT tag_id FROM suggestions
				UNION
				SELECT antecedent FROM aliases
				UNION
				SELECT consequent FROM aliases
				UNION
				SELECT suggestion_id FROM suggestions
			);"
		)
	
	var data_tags: Array[String] = []
	tag_database.query("SELECT tags.id, tags.name, tags.is_valid, IIF(data.tag_id IS NULL, 0, 1) AS has_data FROM tags LEFT JOIN data ON data.tag_id = tags.id;")
	for dict in tag_database.query_result:
		loaded_tags[dict["name"]] = dict["id"]
		if dict["has_data"] == 1:
			data_tags.append(dict["name"])
		if not dict["is_valid"]:
			invalid_tags.append(dict["id"])
	
	var default_color: String = tag_database.select_rows("categories", "id = 1", ["icon_color"])[0]["icon_color"]
	_default_icon_color = Color.from_string(default_color, Color.WHITE)
	
	for icon in tag_database.select_rows("icons", "", ["id", "name"]):
		icons[icon["id"]] = {"name": icon["name"], "texture": null}
	
	invalid_tags.sort()
	data_tags.sort_custom(Arrays.sort_custom_alphabetically_asc)
	get_all_alias_names()
	var all_tags: Array = loaded_tags.keys()
	all_tags.sort_custom(Arrays.sort_custom_alphabetically_asc)
	tag_search_array = PackedStringArray(all_tags)
	tag_search_data = PackedStringArray(data_tags)


func get_icon_name(icon_id: int) -> String:
	return icons[icon_id]["name"]


func get_category_icon_color(category_id: int) -> Color:
	if category_id == 1:
		return _default_icon_color
	
	var result := tag_database.select_rows("categories", "id = " + str(category_id), ["icon_color"])
	if result.is_empty():
		log_message(
				str("Category ", category_id, " could not be fould."),
				LogLevel.ERROR)
		return "ffffff"
	return Color.from_string(result[0]["icon_color"], Color.WHITE)


func get_category_icon_id(category_id: int) ->int:
	var result := tag_database.select_rows("categories", "id = " + str(category_id), ["icon_id"])
	if result.is_empty():
		log_message(
				str("Category ", category_id, " could not be fould."),
				LogLevel.ERROR)
		return 1
	return result[0]["icon_id"]


func get_icon_texture(id: int) -> Texture2D:
	if icons[id]["texture"] == null:
		_load_icon_data(id)
	return icons[id]["texture"]

# --- Groups ---

func get_tag_groups() -> Dictionary:
	var groups: Dictionary = {}
	for group in tag_database.select_rows("groups", "", ["*"]):
		groups[group["id"]] = {"name": group["name"], "description": group["description"]}
	return groups


func remove_tag_group(group_id: int) -> void:
	tag_database.delete_rows("groups", "id = " + str(group_id))
	group_deleted.emit(group_id)


func get_tag_group_data(group_id: int) -> Dictionary:
	var data := tag_database.select_rows("groups", "id = " + str(group_id), ["*"])
	
	var group_data: Dictionary = {
		"name": data[0]["name"] if data[0]["name"] != null else "",
		"description": data[0]["description"] if data[0]["description"] != null else ""}
	
	return group_data


func create_tag_group(group_name: String, group_desc: String) -> int:
	tag_database.insert_row(
			"groups",
			{"name": group_name, "description": group_desc})
	var row: int = tag_database.last_insert_rowid
	group_created.emit(row, group_name)
	return row


func add_group_suggestions(tag: int, groups: Array[int]) -> void:
	var new_cells: Array[Dictionary] = []
	var existing_groups: Array[int] = []
	
	tag_database.query("SELECT group_id FROM group_suggestions WHERE tag_id = " + str(tag) + ";")
	
	for existing in tag_database.query_result:
		existing_groups.append(existing["group_id"])
	
	existing_groups.sort()
	
	for group in groups:
		if Arrays.binary_search(existing_groups, group) == -1:
			new_cells.append({"tag_id": tag, "group_id": group})
	
	tag_database.insert_rows("group_suggestions", new_cells)


func remove_group_suggestions(from_tag: int, groups: Array[int]) -> void:
	var groups_string: String = "(" + ", ".join(groups) + ")"
	tag_database.query("DELETE FROM group_suggestions WHERE tag_id = " + str(from_tag) + " AND group_id IN " + groups_string + ";")


func remove_all_group_suggestions(from_tag: int) -> void:
	tag_database.delete_rows("group_suggestions", "tag_id = " + str(from_tag))


func get_groups_and_tags(groups: Array[int]) -> Dictionary:
	# group_id: group_name, tags:
	var prompt_string: String = "(" + ", ".join(groups) + ")"
	var all_dict: Dictionary = {}
	
	for group_data in tag_database.select_rows("groups", "id IN " + prompt_string, ["id", "name"]):
		all_dict[group_data["id"]] = {
				"group_name": group_data["name"],
				"tags": {}}
	
	tag_database.query(
		"SELECT data.tag_id, data.group_id, tags.name 
		FROM data 
		LEFT JOIN tags ON data.tag_id = tags.id 
		WHERE data.group_id IN " + prompt_string + ";")
	
	for result in tag_database.query_result:
		all_dict[result["group_id"]]["tags"][result["tag_id"]] = result["name"]
	
	return all_dict


# --- Aliases ---

func add_alias(from: String, to: String) -> void:
	var from_id: int = get_tag_id(from) if has_tag(from) else 0
	var to_id: int = get_tag_id(to) if has_tag(to) else 0
	
	if from_id != 0 and to_id != 0:
		tag_database.query("SELECT * FROM aliases WHERE antecedent = " + str(to_id) + " AND consequent = " + str(from_id) + ";")
		if not tag_database.query_result.is_empty():
			log_message(
					str("Circular aliasing detected: ", from, " -> ", to, " -> ", from,".\n Can't register new alias."),
					LogLevel.ERROR)
			return
	
	if from_id == 0:
		create_empty_tag(from)
		from_id = get_tag_id(from)
	if to_id == 0:
		create_empty_tag(to)
		to_id = get_tag_id(to)
	
	tag_database.update_rows("aliases", "consequent = " + str(from_id), {"consequent": to_id})
	
	tag_database.insert_row("aliases", {"antecedent": from_id, "consequent": to_id})


func add_aliases(from: Array[String], to: String) -> void:
	var new_tags: Array[String] = []
	var consequent_id: int = 0
	var new_rows: Array[Dictionary] = []

	for tag in from:
		if not has_tag(tag):
			new_tags.append(tag)
	
	if not has_tag(to) and not new_tags.has(to):
		new_tags.append(to)
	
	if not new_tags.is_empty():
		create_empty_tags(new_tags, true)
	
	consequent_id = get_tag_id(to)
	
	var from_ids: Array[int] = Array(get_tags_ids(from).values(), TYPE_INT, &"", null)
	var from_string = "(" + ",".join(from_ids) + ")"
	
	var existing_aliases: Array[int] = []
	tag_database.query(
			"SELECT antecedent FROM aliases WHERE consequent = " + str(consequent_id) +\
			" AND antecedent in " + from_string + ";")
	for result in tag_database.query_result:
		existing_aliases.append(result["antecedent"])
	existing_aliases.sort()
	
	for from_id in from_ids:
		if Arrays.binary_search(existing_aliases, from_id) == -1:
			new_rows.append(
					{
						"antecedent": from_id,
						"consequent": consequent_id})
	
	tag_database.insert_rows("aliases", new_rows)


func has_alias(tag: int) -> bool:
	return not tag_database.select_rows("aliases", "antecedent = " + str(tag), ["*"]).is_empty()


func get_alias(tag_id: int) -> int:
	return tag_database.select_rows("aliases", "antecedent = " + str(tag_id), ["consequent"])[0]["consequent"]


func get_alias_name(from: String) -> String:
	var tag_id: int = get_tag_id(from)
	tag_database.query(
			"SELECT tags.name 
			FROM aliases 
			JOIN tags ON tags.id = aliases.consequent 
			WHERE aliases.antecedent = " + str(tag_id) + ";")
	if tag_database.query_result.is_empty():
		return from
	else:
		return tag_database.query_result[0]["name"]


func remove_alias(tag_id: int) -> void:
	tag_database.delete_rows("aliases", "antecedent = " + str(tag_id))


func remove_aliases_to(to_alias: int) -> void:
	tag_database.delete_rows("aliases", "consequent = " + str(to_alias))


func remove_aliases(from: Array[int]) -> void:
	var from_string: String = "(" + ", ".join(from) + ")"
	tag_database.query("DELETE FROM aliases WHERE antecedent IN " + from_string + ";")


func get_aliases_to(tag_id: int) -> Array[int]:
	var from_tag: Array[int] = []
	for alias in tag_database.select_rows("aliases", "consequent = " + str(tag_id), ["antecedent"]):
		from_tag.append(alias["antecedent"])
	return from_tag


func get_aliases_consequent_names_from(tag_ids: Array[int]) -> Dictionary:
	var exisiting_aliases: Dictionary = {}
	var promt_search: String = "(" + ",".join(tag_ids) + ")"
	
	tag_database.query(
			"SELECT aliases.antecedent AS antecedent_id, tags.name AS consequent_name 
			FROM aliases 
			JOIN tags ON aliases.consequent = tags.id 
			WHERE aliases.antecedent IN " + promt_search + ";")
	
	for result in tag_database.query_result:
		exisiting_aliases[result["antecedent_id"]] = result["consequent_name"]
	
	return exisiting_aliases


func is_name_aliased(from: String, to: String) -> bool:
	if not has_tag(from) or not has_tag(to):
		return false
	
	var from_id: int = get_tag_id(from)
	var to_id: int = get_tag_id(to)
	
	tag_database.query("SELECT antecedent FROM aliases WHERE antecedent = " + str(from_id) + " AND consequent = " + str(to_id) + ";")
	
	return not tag_database.query_result.is_empty()


func get_all_alias_names() -> Dictionary:
	var all_aliases: Dictionary = {}
	
	tag_database.query(
		"SELECT a_tag.name AS from_tag, c_tag.name AS to_tag 
		FROM aliases 
		JOIN tags a_tag ON a_tag.id = aliases.antecedent 
		JOIN tags c_tag ON c_tag.id = aliases.consequent")
	
	for alias in tag_database.query_result:
		if not all_aliases.has(alias["to_tag"]):
			all_aliases[alias["to_tag"]] = Array([], TYPE_STRING, &"", null)
		all_aliases[alias["to_tag"]].append(alias["from_tag"])
	
	return all_aliases


func search_alias(tag_id: int) -> Dictionary:
	var aliases_found: Dictionary = {}
	tag_database.query(
		"SELECT a_tag.name AS from_tag, c_tag.name AS to_tag 
		FROM aliases 
		JOIN tags a_tag ON a_tag.id = aliases.antecedent 
		JOIN tags c_tag ON c_tag.id = aliases.consequent 
		WHERE antecedent = " + str(tag_id) +\
		" OR consequent = " + str(tag_id) + ";")
	for alias in tag_database.query_result:
		if not aliases_found.has(alias["to_tag"]):
			aliases_found[alias["to_tag"]] = Array([], TYPE_STRING, &"", null)
		aliases_found[alias["to_tag"]].append(alias["from_tag"])
	return aliases_found


func search_aliases(tags: Array[int]) -> Dictionary:
	var query_ids: String = "(" + ", ".join(tags) + ")"
	var aliases_found: Dictionary = {}
	tag_database.query(
		"SELECT a_tag.name AS from_tag, c_tag.name AS to_tag 
		FROM aliases 
		JOIN tags a_tag ON a_tag.id = aliases.antecedent 
		JOIN tags c_tag ON c_tag.id = aliases.consequent 
		WHERE antecedent in " + query_ids +\
		" OR consequent in " + query_ids + ";")
	for alias in tag_database.query_result:
		if not aliases_found.has(alias["to_tag"]):
			aliases_found[alias["to_tag"]] = Array([], TYPE_STRING, &"", null)
		aliases_found[alias["to_tag"]].append(alias["from_tag"])
	return aliases_found


# --- Categories ---

func get_categories() -> Dictionary:
	var all_cats: Dictionary = {}
	
	for category in tag_database.select_rows("categories", "", ["*"]):
		all_cats[category["id"]] = {
		"name": category["name"] if category["name"] != null else "",
		"description": category["description"] if category["description"] != null else "",
		"icon_color": category["icon_color"] if category["icon_color"] != null else "ffffff",
		"icon_id": category["icon_id"]}
	
	return all_cats


func get_category_data(category_id: int) -> Dictionary:
	var data := tag_database.select_rows("categories", "id = " + str(category_id), ["*"])
	var cat_data: Dictionary = {
		"name": data[0]["name"] if data[0]["name"] != null else "",
		"description": data[0]["description"] if data[0]["description"] != null else "",
		"icon_color": data[0]["icon_color"] if data[0]["icon_color"] != null else "ffffff",
		"icon_id": data[0]["icon_id"]}
	return cat_data
	

func get_category_column(category_id: int, column: String) -> Variant:
	return tag_database.select_rows("categories", "id = " + str(category_id), [column])[0][column]


# --- Tags ---

func create_tag(tag_name: String, tag_category: int, tag_desc: String, tag_group: int, tooltip: String = "") -> void:
	if not has_tag(tag_name):
		var new_tag: Dictionary = {
			"name": tag_name,
			"is_valid": 1}
	
		tag_database.insert_row("tags", new_tag)
		
		register_tag_to_memory(tag_database.last_insert_rowid, tag_name, true)
		log_message("Tag created: " + "\"" + tag_name + "\"", LogLevel.INFO)
		#loaded_tags[tag_name] = tag_database.last_insert_rowid #tag_database.select_rows("tags", "tag = '" + tag_name + "'", ["id"])[0]["id"]
	
	var tag_id: int = get_tag_id(tag_name)
	
	@warning_ignore("incompatible_ternary")
	var new_data: Dictionary = {
		"tag_id": tag_id,
		"category_id": tag_category,
		"description": tag_desc if not tag_desc.is_empty() else null,
		"priority": 0,
		"group_id": tag_group if 0 < tag_group else null,
		"tooltip": tooltip if not tooltip.is_empty() else null}
	tag_search_data.insert(tag_search_data.bsearch(tag_name, false), tag_name)
	tag_database.insert_row("data", new_data)
	tag_created.emit(tag_name, tag_id)


func create_empty_tag(tag_name: String) -> void:
	var new_tag: Dictionary = {
		"name": tag_name,
		"is_valid": 1}
	
	tag_database.insert_row("tags", new_tag)
	
	register_tag_to_memory(tag_database.last_insert_rowid, tag_name, true)
	#loaded_tags[tag_name] = tag_database.last_insert_rowid
	
	tag_created.emit(tag_name, get_tag_id(tag_name))
	log_message("Tag created: " + "\"" + tag_name + "\"", LogLevel.INFO)


func create_empty_tags(tags: Array[String], create_valid: bool = true) -> void:
	var new_rows: Array[Dictionary] = []
	for tag in tags:
		new_rows.append({"name": tag, "is_valid": int(create_valid)})
	
	tag_database.insert_rows("tags", new_rows)
	
	tag_database.query(
			"SELECT id, name  
			FROM tags 
			ORDER BY id 
			DESC LIMIT " + str(new_rows.size()) + ";")
	
	for new_tags in tag_database.query_result:
		register_tag_to_memory(new_tags["id"], new_tags["name"], create_valid)
	
	log_message("Tags created: " + ", ".join(tags), LogLevel.INFO)


func get_tag_data_column(tag_id: int, column: String) -> Variant:
	return tag_database.select_rows("data", "tag_id = " + str(tag_id), [column])[0][column]


func get_tag_data_columns(tag_id: int, columns:Array[String]) -> Dictionary:
	var return_columns: Dictionary = {}
	var data := tag_database.select_rows("data", "id = " + str(tag_id), columns)
	
	for column in data[0]:
		columns[column] = data[0][column]
	
	return return_columns


func get_tag_data(tag_id: int) -> Dictionary:
	tag_database.query(
			"SELECT tags.name, tags.is_valid, 
			data.priority, data.category_id, data.description, data.tooltip, data.group_id
			FROM tags 
			LEFT JOIN data ON data.tag_id = tags.id WHERE tags.id = " + str(tag_id) + ";")

	var result: Dictionary = tag_database.query_result[0].duplicate()

	return {
		"tag": result["name"],
		"aliases": get_aliases_to(tag_id),
		"suggestions": get_suggestions(tag_id),
		"parents": get_parents(tag_id),
		"is_valid": bool(result["is_valid"]),
		"priority": result["priority"],
		"category": result["category_id"],
		"description": result["description"] if result["description"] != null else "",
		"tooltip": result["tooltip"] if result["tooltip"] != null else "",
		"group": result["group_id"] if result["group_id"] != null else 0,
		"suggested_groups": get_suggested_groups(tag_id)}


# Will only get tag data in the tag & data tables.
func get_tags_data(tags:Array[int]) -> Dictionary:
	var id_query: String = "(" + ", ".join(tags) + ")"
	var tags_data: Dictionary = {}
	
	tag_database.query(
			"SELECT tags.id, tags.name, tags.is_valid, 
			data.priority, data.category_id, data.description, data.tooltip, data.group_id 
			FROM tags 
			LEFT JOIN data ON data.tag_id = tags.id 
			WHERE tags.id IN " + id_query + ";")
	
	for tag in tag_database.query_result:
		tags_data[tag["id"]] = {
			"tag": tag["name"],
			"is_valid":bool(tag["is_valid"]),
			"priority": tag["priority"],
			"category": tag["category_id"],
			"description": tag["description"] if tag["description"] != null else "",
			"tooltip": tag["tooltip"] if tag["tooltip"] != null else "",
			"group": tag["group_id"] if tag["group_id"] != null else 0}
	
	return tags_data


func delete_tag_data(tag_id: int) -> void:
	var tag_name: String = get_tag_name(tag_id)
	var target_idx: int = tag_search_data.bsearch(tag_name)
	
	tag_database.delete_rows(
			"data",
			"tag_id = " + str(tag_id))
	tag_database.delete_rows(
		"relationships",
		"child = " + str(tag_id))
	
	if tag_search_data[target_idx] == tag_name:
		tag_search_data.remove_at(target_idx)
	
	tag_deleted.emit(tag_id)


func get_all_ids() -> Array[int]:
	return Array(loaded_tags.values(), TYPE_INT, &"", null)


# --- Parents ---

func add_parents(to: int, new_parent_tags: Array) -> void:
	# add is an array full of STRINGS, not integers!
	var add: Array[String] = Array(new_parent_tags, TYPE_STRING, &"", null) # For now
	var new_rows: Array[Dictionary] = [] # Storing the new cells to insert in 1 call
	var existing_parents := tag_database.select_rows(
			"relationships",
			"child = " + str(to),
			["parent"])
	
	var existing_ids: Array[int] = []
	
	for parent in existing_parents:
		existing_ids.append(parent["parent"])
	
	existing_ids.sort()
	
	var new_empty_parents: Array[String] = []
	for parent in add: # Creating all parents in 1 call
		if not has_tag(parent):
			new_empty_parents.append(parent)
	if not new_empty_parents.is_empty():
		create_empty_tags(new_empty_parents)
	var all_tag_ids: Dictionary = get_tags_ids(add)
	
	for parent_string in all_tag_ids: # Assigning parents.
		if Arrays.binary_search(existing_ids, all_tag_ids[parent_string]) == -1:
			new_rows.append({"parent": all_tag_ids[parent_string], "child": to})
	
	tag_database.insert_rows("relationships", new_rows)


func remove_parents(from: int, remove: Array[int]) -> void:
	# parents is an array full of STRINGS, not integers!
	var remove_these: String = "(" + ", ".join(remove) + ")"
	
	tag_database.query("DELETE FROM relationships WHERE child = " + str(from) + " AND parent IN " + remove_these + ";")


func remove_all_parents_from(from: int) -> void:
	tag_database.delete_rows("relationships", "child = " + str(from))


func get_parents(from: int) -> Array[int]:
	var parents: Array[int] = []
	
	for parent in tag_database.select_rows("relationships", "child = " + str(from), ["parent"]):
		parents.append(parent["parent"])
	
	return parents


# Returns the parents from tag_id and the parents from those parents and so on.
func get_parents_recursive(tag_id: int, _queued_parents: Array[int] = [], _iteration: int = 0) -> Array[int]:
	# We get all parents from tag_id
	var all_parents: Array[int] = get_parents(tag_id)
	
	if _iteration == 0:
		# If it's the first call, then also add tag_id to not include it in future searches.
		_queued_parents.append(tag_id)
	elif MAX_PARENT_RECURSION <= _iteration:
		# If we're too deep in recursion, break the loop. Save your base!!!
		# Also it means I did something wrong on the next part of the code.
		return all_parents
	
	# We remove the queued ones from the ones we still need to search:
	# all_parents - queued_parents
	# [0, 1, 2] - [0, 2] = [1]
	Arrays.substract_array(all_parents, _queued_parents)
	# We add all_parents to the queue since they are uniques.
	_queued_parents.append_array(all_parents)
	
	for parent_tag in all_parents: # Now we're only looking for non-queued ones.
		for parent in get_parents(parent_tag):
			# Get them, but also show which ones are already on queue.
			var subparents := get_parents_recursive(parent, _queued_parents, _iteration + 1)
			Arrays.append_uniques(all_parents, subparents) # And only append non-repeats
	
	return all_parents

# --- Suggestions ---

func add_suggestions(to: int, add: Array[String]) -> void:
	#var suggestion_ids: Array[int] = []
	var new_rows: Array[Dictionary] = []
	var existing: Array[int] = []
	
	for suggestion in tag_database.select_rows("suggestions", "tag_id = " + str(to), ["suggestion_id"]):
		existing.append(suggestion["suggestion_id"])
	
	existing.sort()
	
	var new_empty: Array[String] = []
	
	for suggestion in add:
		if not has_tag(suggestion):
			#create_empty_tag(suggestion)
			new_empty.append(suggestion)
	
	if not new_empty.is_empty():
		create_empty_tags(new_empty)
	
	var ids: Array[int] = Array(get_tags_ids(add).values(), TYPE_INT, &"", null)
	
	for add_id in ids:
		if Arrays.binary_search(existing, add_id) == -1:
			new_rows.append({"tag_id": to, "suggestion_id": add_id})
	
	tag_database.insert_rows("suggestions", new_rows)


func remove_suggestions(from: int, remove: Array[int]) -> void:
	var remove_these: String = "(" + ", ".join(remove) + ")"
	
	tag_database.query("DELETE FROM suggestions WHERE tag_id = " + str(from) + " AND suggestion_id IN " + remove_these + ";")


func remove_all_suggestions(from: int) -> void:
	tag_database.delete_rows("suggestions", "tag_id = " + str(from))


func get_suggestions(for_tag: int) -> Array[int]:
	var suggestions: Array[int] = []
	
	for suggestion in tag_database.select_rows("suggestions", "tag_id = " + str(for_tag), ["suggestion_id"]):
		suggestions.append(suggestion["suggestion_id"])
	
	return suggestions


# --- Group Collections ---

func get_suggested_groups(from_tag: int) -> Array[int]:
	var suggested_groups: Array[int] = []
	for group in tag_database.select_rows("group_suggestions", "tag_id = " + str(from_tag), ["group_id"]):
		suggested_groups.append(group["group_id"])
	return suggested_groups
# --- Hydrus Categories ---

func set_hydrus_category_prefix(category_id: int, prefix: String) -> void:
	if tag_database.select_rows("hydrus_prefixes", "category_id = " + str(category_id), ["category_id"]).is_empty():
		tag_database.insert_row("hydrus_prefixes", {"category_id": category_id, "prefix": prefix})
	else:
		tag_database.update_rows("hydrus_prefixes", "category_id = " + str(category_id), {"prefix": prefix})


func remove_hydrus_category_prefix(category_id: int) -> void:
	tag_database.delete_rows("hydrus_prefixes", "category_id = " + str(category_id))


func get_hydrus_category_prefix(category_id: int) -> String:
	var data := tag_database.select_rows("hydrus_prefixes", "category_id = " + str(category_id), ["prefix"])
	if data.is_empty():
		return ""
	return data[0]["prefix"]

# --- Sites ---

func create_site(site_name: String, tag_whitespace: String, tag_separator: String) -> int:
	tag_database.insert_row(
			"sites",
			{
				"name": site_name,
				"whitespace": tag_whitespace,
				"separator": tag_separator
			})
	website_created.emit(tag_database.last_insert_rowid, site_name)
	return tag_database.last_insert_rowid


func delete_site(site_id: int) -> void:
	tag_database.delete_rows("sites", "id = " + str(site_id))
	website_deleted.emit(site_id)


func get_site_data(site_id: int) -> Dictionary:
	var site := tag_database.select_rows("sites", "id = " + str(site_id), ["*"])
	return {
		"name": site[0]["name"],
		"whitespace": site[0]["whitespace"],
		"separator": site[0]["separator"]}


func get_site_formatting(site_id: int) -> Dictionary:
	var site := tag_database.select_rows("sites", "id = " + str(site_id), ["whitespace", "separator"])
	return {
		"whitespace": site[0]["whitespace"],
		"separator": site[0]["separator"]}


func get_sites() -> Dictionary:
	var all_sites: Dictionary = {}
	for site in tag_database.select_rows("sites", "", ["*"]):
		all_sites[site["id"]] = {
			"name": site["name"] if site["name"] != null else "",
			"whitespace": site["whitespace"],
			"separator": site["separator"]}
	return all_sites


func get_site_count() -> int:
	tag_database.query("SELECT COUNT(id) FROM sites;")
	return tag_database.query_result[0]["COUNT(id)"]


# ---- Table Updaters ----

func update_category(category_id: int, category_data: Dictionary) -> void:
	tag_database.update_rows(
			"categories",
			"id = " + str(category_id),
			category_data)


func update_group(group_id: int, group_data: Dictionary) -> void:
	tag_database.update_rows(
			"groups",
			"id = " + str(group_id),
			group_data)


# This one updates only the entry. Only editable data is the name and if it's valid.
func update_tag(tag_id: int, update_data: Dictionary) -> void:
	tag_database.update_rows("tags", "id = " + str(tag_id), update_data)


# This one contains further data linked to the tag. Wiki, desc, tooltip, etc.
func update_tag_data(tag_id: int, update_data: Dictionary) -> void:
	tag_database.update_rows("data", "tag_id = " + str(tag_id), update_data)
	tag_updated.emit(tag_id)


# --- Utility ---

func get_all_tag_ids(with_data: bool) -> Array[int]:
	if with_data:
		var all_tags: Array[int] = []
		for result in tag_database.select_rows("data", "", ["tag_id"]):
			all_tags.append(result["tag_id"])
		return all_tags
	else:
		return Array(loaded_tags.values(), TYPE_INT, &"", null)


func get_all_tag_names(with_data: bool) -> Array[String]:
	var all_tags: Array[String] = []
	if with_data:
		tag_database.query("SELECT tags.name FROM data LEFT JOIN tags ON data.tag_id = tags.id")
		for result in tag_database.query_result:
			all_tags.append(result["name"])
		return all_tags
	else:
		return Array(loaded_tags.keys(), TYPE_STRING, &"", null)


func get_tag_id(tag_name: String) -> int:
	return loaded_tags[tag_name]


func get_tags_ids(tag_array: Array[String]) -> Dictionary:
	var return_dict: Dictionary = {}
	for tag in tag_array:
		if has_tag(tag):
			return_dict[tag] = get_tag_id(tag)
	return return_dict


# Use when you need to get the name of 1 tag. If you need a huge number
# better use "get_tags_name"
func get_tag_name(tag_id: int) -> String:
	return tag_database.select_rows("tags", "id = " + str(tag_id), ["name"])[0]["name"]


# preserve_order makes sure that the result names match the order of the given id_list.
func get_tags_name(id_list: Array[int]) -> Dictionary:
	var tag_names: Dictionary = {}
	var string_ids: String = "(" + ", ".join(id_list) + ")"
	tag_database.query("SELECT id, name FROM tags WHERE id IN " + string_ids + ";")
	

	for result in tag_database.query_result:
		tag_names[result["id"]] = result["name"]
	
	return tag_names


func get_tags(id_list: Array[int]) -> Dictionary:
	var tags_dict: Dictionary = {}
	var string_ids: String = "(" + ", ".join(id_list) + ")"
	tag_database.query("SELECT * FROM tags WHERE id IN " + string_ids + ";")
	for tag in tag_database.query_result:
		tags_dict[tag["id"]] = {"name": tag["name"], "is_valid": tag["is_valid"]}
	return tags_dict



func has_data(tag_id: int) -> bool:
	return not tag_database.select_rows("data", "tag_id = " + str(tag_id), ["id"]).is_empty()


func has_tag(tag_name: String) -> bool: 
	# We use this because we already have the names loaded in memory. Faster this way.
	return loaded_tags.has(tag_name)


func has_tag_id(tag_id: int) -> bool:
	#return not tag_database.select_rows("tag", "id = " + str(tag_id), ["id"]).is_empty()
	return not loaded_tags.values().has(tag_id)


func is_tag_valid(id: int) -> bool:
	return Arrays.binary_search(invalid_tags, id) == -1


# For single updates
func set_tag_valid(tag_id: int, is_valid: bool) -> void:
	var valid: bool = is_tag_valid(tag_id)
	
	if valid == is_valid: # Only update if needed.
		return
	
	update_tag(tag_id, {"is_valid": int(is_valid)})
	
	if is_valid:
		invalid_tags.remove_at(Arrays.binary_search(invalid_tags, tag_id))
	else:
		Arrays.insert_sorted_asc(invalid_tags, tag_id)
	
	tags_validity_updated.emit(Array([tag_id], TYPE_INT, &"", null), is_valid)


# For mass updating.
func set_tags_valid(tag_ids: Array[int], is_valid: bool) -> void:
	var ids_string: String = "(" + ", ".join(tag_ids) + ")"
	tag_database.query(
		"UPDATE tags 
		SET is_valid = " + str(int(is_valid)) +\
		" WHERE id IN " + ids_string + ";")
	
	for tag in tag_ids:
		if is_valid:
			var invalid_idx: int = Arrays.binary_search(invalid_tags, tag)
			if invalid_idx != -1:
				invalid_tags.remove_at(invalid_idx)
		else:
			Arrays.insert_sorted_asc(invalid_tags, tag)
	
	tags_validity_updated.emit(tag_ids.duplicate(), is_valid)


func resize_image(image: Image) -> void:
	var image_res: Vector2i = image.get_size()
	
	if IMAGE_LIMITS.x < image_res.x or IMAGE_LIMITS.y < image_res.y:
		if image_res.x < image_res.y: # Taller
			var new_width: float = (IMAGE_LIMITS.y * 1.0 / float(image_res.y)) * image_res.x
			image.resize(roundi(new_width), IMAGE_LIMITS.y, Image.INTERPOLATE_LANCZOS)
		else:
			var new_height: float = (IMAGE_LIMITS.x * 1.0 / float(image_res.x)) * image_res.y
			image.resize(IMAGE_LIMITS.x, roundi(new_height), Image.INTERPOLATE_LANCZOS)


# --- Prefixes ---
func get_prefixes_data() -> Array[Dictionary]:
	return tag_database.select_rows("prefixes", "", ["*"])


func get_prefixes() -> PackedStringArray:
	var all_prefixes := PackedStringArray()
	for preffix_row in tag_database.select_rows("prefixes", "", ["prefix"]):
		all_prefixes.append(preffix_row["prefix"])
	return all_prefixes


func has_prefix(prefix: String) -> bool:
	return not tag_database.select_rows("prefixes", str("prefix = '", prefix, "'"), ["prefix"]).is_empty()


func get_prefix_formatting(prefix: String) -> String:
	return tag_database.select_rows("prefixes", str("prefix = '", prefix, "'"), ["format"])[0]["format"]


func add_prefix(prefix: String, formatting: String) -> void:
	tag_database.insert_row("prefixes", {"prefix": prefix, "format": formatting})


func erase_prefix(prefix: String) -> void:
	tag_database.delete_rows("prefixes", str("prefix = '", prefix, "'"))


func update_prefix(prefix: String, formatting: String) -> void:
	tag_database.update_rows("prefixes", str("prefix = '", prefix, "'"), {"format": formatting})


func format_prefix(clean_text: String, _prefixes: Array[String] = [], _formats: Array[String] = [], _search: bool = true, _starting_prefix: String = "") -> Array[String]:
	if _starting_prefix == clean_text:
		return [clean_text]
	
	if _search:
		var prefix_dict: Dictionary = {}
		var prefixes: Array[String] = []
		for prefix_tree in get_prefixes_data():
			prefix_dict[prefix_tree["prefix"]] = prefix_tree["format"]
			prefixes.append(prefix_tree["prefix"])
		prefixes.sort_custom(func(a: String, b: String): return a.length() > b.length())
		for prefix in prefixes:
			_formats.append(prefix_dict[prefix])
		_prefixes = prefixes
	var final_array: Array[String] = []
	
	for part in Strings.split_and_strip(clean_text, "|"):
		var prefixed: bool = false
		var prefix_idx: int = -1
		for prefix in _prefixes:
			prefix_idx += 1
			if Strings.begins_with_nocasecmp(part, prefix):
				var trimmed_string: String = part.trim_prefix(prefix)
				var args: Array[String] = Strings.split_and_strip(trimmed_string, ",")
				var format: String = _formats[prefix_idx].format(args)
				Arrays.append_uniques(
						final_array,
						format_prefix(
								format,
								_prefixes,
								_formats,
								false,
								clean_text if _search else _starting_prefix))
				prefixed = true
				break
		if not prefixed:
			Arrays.append_uniques(final_array, [part])
	
	return final_array

# --------------


func get_final_tag_ids(current_list: Array[int]) -> Array[int]:
	var all_tags: Array[int] = []
	var final_tags: Array[int] = []
	
	all_tags.assign(current_list)
	all_tags.sort()
	
	for tag in current_list:
		var parents: Array[int] = get_parents_recursive(tag)
		
		for parent_tag in parents:
			var tag_id: int = Arrays.binary_search(all_tags, parent_tag)
			if tag_id == -1:
				Arrays.insert_sorted_asc(all_tags, parent_tag)

	var id_query: String = "(" + ",".join(all_tags) + ")"
	
	tag_database.query( # id, priority, iS_valid
			"SELECT id, is_valid FROM tags WHERE id IN " + 
			id_query + ";")
	
	for query in tag_database.query_result:
		if not query["is_valid"] and not TagIt.settings.include_invalid:
			continue
		
		final_tags.append(query["id"])
	
	return final_tags


func sort_tag_ids_by_priority(tag_ids: Array[int]) -> Dictionary:
	var sorted_ids: Dictionary = {}
	var editing := tag_ids.duplicate()
	editing.sort()
	var query_string: String = "(" + ", ".join(tag_ids) + ")"
	tag_database.query(
		"SELECT tag_id, priority FROM data WHERE tag_id IN " + query_string + ";")
	
	for tag in tag_database.query_result:
		if not sorted_ids.has(tag["priority"]):
			sorted_ids[tag["priority"]] = Array([], TYPE_INT, &"", null)
		sorted_ids[tag["priority"]].append(tag["tag_id"])
		editing.remove_at(Arrays.binary_search(editing, tag["tag_id"]))
	
	if not editing.is_empty():
		if not sorted_ids.has(0):
			sorted_ids[0] = Array([], TYPE_INT, &"", null)
		sorted_ids[0].append_array(editing)
	
	return sorted_ids


func register_tag_to_memory(tag_id: int, tag_name: String, is_valid: bool) -> void:
	loaded_tags[tag_name] = tag_id
	if not is_valid:
		invalid_tags.append(tag_id)
	tag_search_array.insert(tag_search_array.bsearch(tag_name), tag_name)


#region Convenience Methods
# These methods just simplify things, even if they are repeating code.
# Lazyness for the win.
# ---------- Updaters ----------

func set_tag_desc(tag_id: int, desc: String) -> void:
	update_tag_data(tag_id, {"description": desc})


func set_tag_category(tag_id: int, category_id: int) -> void:
	update_tag_data(tag_id, {"category": category_id})


func set_tag_priority(tag_id: int, priority: int) -> void:
	update_tag_data(tag_id, {"priority": priority})


func set_tag_tooltip(tag_id: int, tooltip: String) -> void:
	update_tag_data(tag_id, {"tooltip": tooltip})


func set_tag_group(tag_id: int, group_id: int) -> void:
	update_tag_data(tag_id, {"tag_group": group_id})


# Do what needs before quitting. Then quit
func quit_request() -> void:
	tag_database.close_db()
	settings.save()
	get_tree().quit()


func search_for_tag_prefix(text: String, limit: int = 10, use_distance: bool = false, with_data: bool = false) -> PackedStringArray:
	var target_array: PackedStringArray = tag_search_data if with_data else tag_search_array
	var results: PackedStringArray = []
	var search_index: int = target_array.bsearch(text)
	var current: int = 0
	var loop: int = 0
	var max_index: int = target_array.size() - 1
	
	if max_index < search_index:
		return results
	
	var distance: float = 0.0
	
	while current < limit:
		loop += 1
		
		if use_distance:
			distance = Strings.levenshtein_distance(text.to_upper(), target_array[search_index].substr(0, text.length()).to_upper())
		else:
			distance = 1.0 if target_array[search_index].to_upper().begins_with(text.to_upper()) else 0.0
		
		if LEV_DISTANCE <= distance:
			current += 1
			results.append(target_array[search_index])
		
		if max_index < search_index + 1 or (LEV_LOOP_LIMIT <= loop and use_distance):
			break
		
		search_index += 1
	
	return results


func search_for_tag_suffix(text: String, limit: int = 10, use_distance: bool = false, with_data: bool = false) -> PackedStringArray:
	var target_array: PackedStringArray = tag_search_data if with_data else tag_search_array
	var results: PackedStringArray = []
	var current: int = 0
	var loop: int = 0
	
	for tag in target_array:
		var distance = 0.0
		loop += 1
		
		if use_distance:
			distance = Strings.levenshtein_distance(text.to_upper(), tag.substr(maxi(0, tag.length() - text.length())).to_upper())
		else:
			distance = 1.0 if tag.to_upper().ends_with(text.to_upper()) else 0.0
		
		if LEV_DISTANCE <= distance:
			current += 1
			results.append(tag)
		
		if limit <= current or (LEV_LOOP_LIMIT <= loop and use_distance):
			break
	
	return results


func search_for_tag_contains(text: String, limit: int = 10, use_distance: bool = false, with_data: bool = false) -> PackedStringArray:
	var target_array: PackedStringArray = tag_search_data if with_data else tag_search_array
	var results: PackedStringArray = []
	var current: int = 0
	var loop: int = 0
	
	for tag in target_array:
		loop += 1
		if use_distance:
			for i in range(tag.length() - text.length() + 1):
				var piece = tag.substr(i, text.length())
				if LEV_DISTANCE <= Strings.levenshtein_distance(text.to_upper(), piece.to_upper()):
					current += 1
					results.append(tag)
					break
		else:
			if tag.contains(text):
				current += 1
				results.append(tag)
		
		if limit <= current or (LEV_LOOP_LIMIT <= loop and use_distance):
			break
	
	return results


func save_icon(icon_name: String, icon_image: Image) -> int:
	if Vector2i(16, 16) != icon_image.get_size():
		icon_image.resize(16, 16, Image.INTERPOLATE_LANCZOS)
	
	tag_database.insert_row(
			"icons",
			{"name": icon_name, "image": icon_image.save_webp_to_buffer()})
	
	icons[tag_database.last_insert_rowid] = {"name": icon_name, "texture": null}
	
	return tag_database.last_insert_rowid


func delete_icon(icon_id: int) -> void:
	tag_database.delete_rows("icons", "id = " + str(icon_id))
	icons.erase(icon_id)


func delete_category(category_id: int) -> void:
	tag_database.delete_rows("categories", "id = " + str(category_id))
	category_deleted.emit(category_id)


func create_category(category_name: String, category_desc: String) -> int:
	@warning_ignore("incompatible_ternary")
	tag_database.insert_row(
		"categories",
		{
			"name": category_name if not category_name.is_empty() else null,
			"description": category_desc if not category_desc.is_empty() else null,
			"icon_id": 1,
			"icon_color": "ffffff"
		})
	
	var cat_id: int = tag_database.last_insert_rowid
	category_created.emit(cat_id)
	return cat_id


func set_category_icon(category_id: int, icon_id: int) -> void:
	update_category(category_id, {"icon_id": icon_id})
	category_icon_updated.emit(category_id, icon_id)


func set_category_icon_color(category_id: int, color: String) -> void:
	update_category(category_id, {"icon_color": color})
	if category_id == 1:
		_default_icon_color = Color.from_string(color, Color.WHITE)
	category_color_updated.emit(category_id, color)


func set_category_name(category_id: int, new_name: String) -> void:
	update_category(category_id, {"name": new_name})


func set_group_desc(group_id: int, desc: String) -> void:
	tag_database.update_rows(
		"groups",
		"id = " + str(group_id),
		{"description": desc})

# ------------------------------
#endregion


func show_splash() -> void:
	if splash_node != null:
		return
	
	splash_node = CanvasLayer.new()
	splash_node.layer = 2
	add_child(splash_node)
	var new_splash := TextureRect.new()
	new_splash.texture = preload("res://textures/splash.png")
	splash_node.add_child(new_splash)


func hide_splash() -> void:
	if splash_node == null:
		return
	splash_node.queue_free()
	splash_node = null


func is_online_version_higher(local: Array[int], online: Array[int]) -> bool:
	var max_length = max(local.size(), online.size())
	local.resize(max_length)
	online.resize(max_length)
	
	for i in range(max_length):
		if local[i] < online[i]:
			return true # Online is higher
		elif local[i] > online[i]:
			return false # Local is higher
	
	return false # Versions are equal


func log_message(message: String, log_level: LogLevel) -> void:
	var log_msg: String = str("[", Time.get_time_string_from_system(), "]")
	
	match log_level:
		LogLevel.INFO:
			log_msg += "[INFO] " + message
			print(log_msg)
		LogLevel.WARNING:
			log_msg += "[WARNING] " + message
			push_warning(log_msg)
		LogLevel.ERROR:
			log_msg += "[ERROR] " + message
			push_error(log_msg)
	
	message_logged.emit(log_msg)
