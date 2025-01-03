extends OptionButton


func _ready() -> void:
	var websites := TagIt.get_sites()
	for site in websites:
		add_item(websites[site]["name"], site)
	select(clampi(
			TagIt.settings.default_site,
			-1 if websites.is_empty() else 0,
			websites.size() - 1))
	TagIt.website_created.connect(on_website_created)
	TagIt.website_deleted.connect(on_website_deleted)


func on_website_created(site_id: int, site_name: String) -> void:
	add_item(site_name, site_id)


func on_website_deleted(site_id: int) -> void:
	var current: int = selected
	remove_item(get_item_index(site_id))
	if current != selected:
		item_selected.emit(selected)


func get_selected_website_id() -> int:
	return get_item_id(selected)
