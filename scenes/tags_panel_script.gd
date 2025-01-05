extends PanelContainer

@onready var all_tags_search_ln_edt: LineEdit = $TagsMargin/TagSearchContainer/MenuContainer/AllTagsSearchLnEdt


func _ready() -> void:
	all_tags_search_ln_edt.timer_finished.connect(on_search_timer_timeout)


func on_search_timer_timeout() -> void:
	var clean_text: String = all_tags_search_ln_edt.text.strip_edges()
	var prefix: bool = clean_text.ends_with(TagIt.SEARCH_WILDCARD)
	var suffix: bool = clean_text.begins_with(TagIt.SEARCH_WILDCARD)
	
	if prefix:
		clean_text = clean_text.trim_prefix(TagIt.SEARCH_WILDCARD).strip_edges(true, false)
	if suffix:
		clean_text = clean_text.trim_suffix(TagIt.SEARCH_WILDCARD).strip_edges(false, true)
	
	while clean_text.begins_with(TagIt.SEARCH_WILDCARD):
		clean_text = clean_text.trim_prefix(TagIt.SEARCH_WILDCARD).strip_edges(true, false)
	
	while clean_text.ends_with(TagIt.SEARCH_WILDCARD):
		clean_text = clean_text.trim_suffix(TagIt.SEARCH_WILDCARD).strip_edges(false, true)
	
	if clean_text.is_empty():
		return
	
	var results: PackedStringArray = []
	
	if prefix and suffix:
		results = TagIt.search_for_tag_contains(clean_text, all_tags_search_ln_edt.item_limit, true, true)
	elif suffix:
		results = TagIt.search_for_tag_suffix(clean_text, all_tags_search_ln_edt.item_limit, true, true)
	else:
		results = TagIt.search_for_tag_prefix(clean_text, all_tags_search_ln_edt.item_limit, true, true)
	
	if not results.is_empty():
		all_tags_search_ln_edt.add_items(results)
		all_tags_search_ln_edt.show_items()
