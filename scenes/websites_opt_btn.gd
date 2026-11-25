extends OptionButton


func _ready() -> void:
	var websites := SingletonManager.TagIt.get_sites()
	for site in websites:
		add_item(websites[site]["name"], site)
	select(clampi(
			SingletonManager.TagIt.settings.default_site,
			-1 if websites.is_empty() else 0,
			websites.size() - 1))
	SingletonManager.TagIt.website_created.connect(on_website_created)
	SingletonManager.TagIt.website_deleted.connect(on_website_deleted)
	SingletonManager.TagIt.website_updated.connect(_on_website_updated)


func on_website_created(site_id: int, site_name: String) -> void:
	add_item(site_name, site_id)


func on_website_deleted(site_id: int) -> void:
	var current: int = selected
	remove_item(get_item_index(site_id))
	if current != selected:
		item_selected.emit(selected)


func _on_website_updated(site: int, rows: Dictionary) -> void:
	if not rows.has("name"):
		return
	
	for idx in item_count:
		if get_item_id(idx) == site:
			set_item_text(idx, rows["name"])
			break


func get_selected_website_id() -> int:
	return get_item_id(selected)
