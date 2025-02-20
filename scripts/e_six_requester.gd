class_name ESixManager
extends Node


signal request_get(request_response: Array)
#signal implications_get(request_response: Array)
signal prio_get(request_response: Array)
signal suggestions_found(for_tag: String, suggestions: Array[String])
signal tag_search_results_found(for_tag: String, tags: PackedStringArray)
signal wiki_responded(tag: String, wiki: String, parents: PackedStringArray, aliases: PackedStringArray, suggestions: PackedStringArray)

enum JobTypes {
	WIKI,
	SUGGESTION,
	ALIAS,
	PARENTS,
}

const ENDPOINT_TAGS: String = "https://e621.net/tags.json?"
const ENDPOINT_ALIASES: String = "https://e621.net/tag_aliases.json?search[name_matches]="
const ENDPOINT_PARENTS: String = "https://e621.net/tag_implications.json?search[antecedent_name]="
const ENDPOINT_WIKI: String = "https://e621.net/wiki_pages.json?limit=1&title="
const HEADERS: PackedStringArray = [
	"User-Agent: TaglistMaker/3.2.4 (by Ketei)"
]

@export var suggestion_limit: int = 30

var requester: HTTPRequest
var priority_requester: HTTPRequest
var wiki_requester: HTTPRequest

var jobs: Array[Dictionary] = []

var job_timer: Timer
var wiki_timer: Timer
var regex: RegEx

var working: bool = false
var prio_working: bool = false
var wiki_working: bool = false


func _ready() -> void:
	requester = HTTPRequest.new()
	requester.timeout = 10
	requester.request_completed.connect(on_request_completed)
	add_child(requester)
	priority_requester = HTTPRequest.new()
	priority_requester.timeout = 10
	priority_requester.request_completed.connect(on_prio_request_completed)
	add_child(priority_requester)
	wiki_requester = HTTPRequest.new()
	wiki_requester.timeout = 10
	wiki_requester.request_completed.connect(on_prio_request_completed)
	add_child(wiki_requester)
	regex = RegEx.new()
	job_timer = Timer.new()
	job_timer.autostart = false
	job_timer.one_shot = true
	job_timer.wait_time = 1.2
	job_timer.timeout.connect(on_timer_timeout)
	add_child(job_timer)
	wiki_timer = Timer.new()
	wiki_timer.autostart = false
	wiki_timer.one_shot = true
	wiki_timer.wait_time = 1.0
	add_child(wiki_timer)


func close_esix_api() -> void:
	if working:
		jobs.clear()
		if not job_timer.is_stopped():
			job_timer.stop()
		requester.cancel_request()
	if prio_working:
		priority_requester.cancel_request()
	if wiki_working:
		if not wiki_timer.is_stopped():
			wiki_timer.stop()
		wiki_requester.cancel_request()


func get_tag_request_url(tag_name: String, order := "date", limit: int = 75) -> String:
	var request_url: String = ENDPOINT_TAGS +\
			"search[name_matches]=" + tag_name +\
			"&search[order]=" + order +\
			"&limit=" + str(clampi(limit, 1, 320))
	
	#if category != E621_CATEGORY.ALL:
		#request_url += "&search[category]=" + str(category)
	
	return request_url


func queue_job(url: String, job_type: JobTypes) -> void:
	working = true
	jobs.append({"url": url, "type": job_type})
	
	if job_timer.is_stopped():
		job_timer.start()


## Searches suggestions for a tag
func search_suggestions(for_tag: String) -> void:
	SingletonManager.TagIt.log_silent("[eSIx API] Queueing request for tag \"" + for_tag + "\"", DataManager.LogLevel.INFO)
	queue_job(
			get_tag_request_url(for_tag, "count", 1),
			JobTypes.SUGGESTION)


func search_for_wiki(tag: String) -> void:
	if wiki_working:
		return
	
	wiki_working = true
	
	if not wiki_timer.is_stopped():
		await wiki_timer.timeout
	
	var json = JSON.new()
	var wiki: String = ""
	var parents: PackedStringArray = []
	var aliases: PackedStringArray = []
	var suggestions: PackedStringArray = []
	
	wiki_timer.start()
	SingletonManager.TagIt.log_message(
			"[eSix API] Requesting e621 for WIKI.",
			DataManager.LogLevel.INFO)
	SingletonManager.TagIt.log_silent(
		"[eSix API] Requesting e621 for tag: " + tag,
		DataManager.LogLevel.INFO)
	wiki_requester.request(ENDPOINT_WIKI + tag, HEADERS)
	
	var result = await wiki_requester.request_completed
	
	if result[0] == HTTPRequest.RESULT_SUCCESS and result[1] == 200:
		SingletonManager.TagIt.log_silent(
				"[eSix API] WIKI request successful",
				DataManager.LogLevel.INFO)
		if json.parse(result[3].get_string_from_utf8()) == OK and typeof(json.data) == TYPE_ARRAY and not json.data.is_empty():
			if typeof(json.data[0]) == TYPE_DICTIONARY and json.data[0].has("body") and not json.data[0]["body"].is_empty():
				wiki = format_esix_wiki(json.data[0]["body"])
	else:
		SingletonManager.TagIt.log_silent(
		str("[eSix API] WIKI request failed: ", result[0], "/", result[1]),
		DataManager.LogLevel.INFO)
	
	if not wiki_timer.is_stopped():
		await wiki_timer.timeout
	
	wiki_timer.start()
	
	SingletonManager.TagIt.log_message(
			"[eSix API] Requesting e621 for PARENTS.",
			DataManager.LogLevel.INFO)
	wiki_requester.request(ENDPOINT_PARENTS + tag, HEADERS)
	
	var p_res = await wiki_requester.request_completed
	
	if p_res[0] == HTTPRequest.RESULT_SUCCESS and p_res[1] == 200:
		SingletonManager.TagIt.log_silent(
				"[eSix API] PARENTS request successful",
				DataManager.LogLevel.INFO)
		if json.parse(p_res[3].get_string_from_utf8()) == OK and typeof(json.data) == TYPE_ARRAY and not json.data.is_empty():
			for dict_item in json.data:
				if typeof(dict_item) != TYPE_DICTIONARY or dict_item["status"] != "active" or not dict_item.has("descendant_names"):
					continue
				for descendant_name in dict_item["descendant_names"]:
					if not parents.has(descendant_name):
						parents.append(descendant_name)
	else:
		SingletonManager.TagIt.log_silent(
		str("[eSix API] PARENTS request failed: ", result[0], "/", result[1]),
		DataManager.LogLevel.INFO)
	
	if not wiki_timer.is_stopped():
		await wiki_timer.timeout
	
	wiki_timer.start()
	SingletonManager.TagIt.log_message(
			"[eSix API] Requesting e621 for ALIASES.",
			DataManager.LogLevel.INFO)
	wiki_requester.request(ENDPOINT_ALIASES + tag, HEADERS)
	
	var a_res = await wiki_requester.request_completed
	
	if a_res[0] == HTTPRequest.RESULT_SUCCESS and a_res[1] == 200:
		SingletonManager.TagIt.log_silent(
				"[eSix API] ALIASES request successful",
				DataManager.LogLevel.INFO)
		if json.parse(a_res[3].get_string_from_utf8()) == OK and typeof(json.data) == TYPE_ARRAY and not json.data.is_empty():
			for alias_dict in json.data:
				if typeof(alias_dict) != TYPE_DICTIONARY or not alias_dict.has("antecedent_name"):
					continue
				if not aliases.has(alias_dict["antecedent_name"]):
					aliases.append(alias_dict["antecedent_name"])
	else:
		SingletonManager.TagIt.log_silent(
		str("[eSix API] ALIASES request failed: ", result[0], "/", result[1]),
		DataManager.LogLevel.INFO)
	
	if not wiki_timer.is_stopped():
		await wiki_timer.timeout
	
	wiki_timer.start()
	SingletonManager.TagIt.log_message(
			"[eSix API] Requesting e621 for SUGGESTIONS.",
			DataManager.LogLevel.INFO)
	wiki_requester.request(ENDPOINT_TAGS + "limit=1&search[name_matches]=" + tag, HEADERS)
	
	var s_res = await wiki_requester.request_completed
	
	if s_res[0] == HTTPRequest.RESULT_SUCCESS and s_res[1] == 200:
		SingletonManager.TagIt.log_silent(
				"[eSix API] SUGGESTIONS request successful",
				DataManager.LogLevel.INFO)
		if json.parse(s_res[3].get_string_from_utf8()) == OK and typeof(json.data) == TYPE_ARRAY and not json.data.is_empty():
			if typeof(json.data[0]) == TYPE_DICTIONARY and json.data[0].has("related_tags") and not json.data[0]["related_tags"].is_empty():
				var strength_tags: Dictionary = parse_tag_strength(json.data[0]["related_tags"])
				
				for strength_key in strength_tags.keys():
					if 70 <= float(strength_key):
						suggestions.append_array(PackedStringArray(strength_tags[strength_key]))
	else:
		SingletonManager.TagIt.log_silent(
		str("[eSix API] SUGGESTIONS request failed: ", result[0], "/", result[1]),
		DataManager.LogLevel.INFO)
	
	SingletonManager.TagIt.log_message(
			"[eSix API] WIKI request completed.",
			DataManager.LogLevel.INFO)
	
	wiki_working = false
	wiki_responded.emit(tag, wiki, parents, aliases, suggestions)


func format_esix_wiki(text_from_wiki: String) -> String:
	regex.clear()
	regex.compile("[Tt]humb #\\d+\\s*")
	var return_string: String = regex.sub( # clears "thumb #XXXX"
		text_from_wiki,
		"",
		true)
	
	regex.clear()
	regex.compile("(?m)^(?:\\*+(?:.*)?\\n*)+")
	for result in regex.search_all(text_from_wiki):
		return_string = return_string.replace(result.get_string(), format_nested_list(result.get_string()))
	
	regex.clear()
	regex.compile("\\[\\[[^|\\]]+\\]\\]") # Finds [[*]]
	for new_url:RegExMatch in regex.search_all(return_string):
		var url = new_url.get_string().trim_prefix("[[").trim_suffix("]]").replace("_", " ")
		return_string = return_string.replace(new_url.get_string(), "[color=AQUAMARINE][url]{0}[/url][/color]".format([url]))	
	
	regex.clear()
	regex.compile("\\[\\[[^|\\]]+\\|[^|\\]]+\\]\\]") # Finds special urls
	for custom_url:RegExMatch in regex.search_all(return_string):
		var array: Array = custom_url.get_string().trim_prefix("[[").trim_suffix("]]").replace("_", " ").split("|")
		return_string = return_string.replace(custom_url.get_string(), "[color=AQUAMARINE][url={0}]{1}[/url][/color]".format(array))

	regex.clear()
	regex.compile("h5\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h5.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=18][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("(?m)^h4\\..*\\n")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h4.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=20][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("h3\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h3.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=22][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("h2\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h2.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=25][b]{0}[/b][/font_size]".format([header_four]))
	
	regex.clear()
	regex.compile("h1\\..*")
	for header:RegExMatch in regex.search_all(return_string):
		var header_four = header.get_string().trim_prefix("h1.").strip_edges()
		return_string = return_string.replace(header.get_string(), "[font_size=27][b]{0}[/b][/font_size]".format([header_four]))
	
	return return_string


func on_timer_timeout() -> void:
	if not jobs.is_empty():
		var req_url: Dictionary = jobs.pop_front()
		SingletonManager.TagIt.log_message("[eSIx API] Making a request to e621", DataManager.LogLevel.INFO)
		requester.request(req_url["url"], HEADERS)
		var response: Array = await request_get
		SingletonManager.TagIt.log_message("[eSix API] Response received", DataManager.LogLevel.INFO)
		process_response(response, req_url["type"])
		job_timer.start()
	else:
		working = false


func process_response(response: Array, response_type: JobTypes) -> void:
	if response.is_empty():
		suggestions_found.emit("", [])
		return
	
	if response_type == JobTypes.SUGGESTION:
		var suggestion_array: Dictionary = parse_tag_strength(
				response[0]["related_tags"])
		
		var suggestions: Array[String] = []
		
		for strength in suggestion_array:
			if int(strength) < SingletonManager.TagIt.settings.suggestion_relevancy:
				continue
			for item: String in suggestion_array[strength]:
				suggestions.append(item.replace("_", " "))
		suggestions_found.emit(response[0]["name"], suggestions)


func on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var response: Array = []
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		SingletonManager.TagIt.log_message(
			"[eSixAPI] An error was encountered with the request.\nEngine result code: " + str(result) + "\ne621 response code: " + str(response_code),
			DataManager.LogLevel.WARNING)
		request_get.emit(response)
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error == OK:
		var pre_json = json.get_data()
		if pre_json is Array:
			response = pre_json # Should be Array[Dictionary]
	else:
		SingletonManager.TagIt.log_message(
			"[eSix API] Error parsing response data: " + json.get_error_message(),
			DataManager.LogLevel.INFO
		)
	
	request_get.emit(response)


# Searches for tags
func search_for_tags(tag_query: String) -> void:
	var tags_found := PackedStringArray()
	request_prio(get_tag_request_url(tag_query, "count", 100))
	var result: Array = await prio_get
	
	for item_dict in result:
		if item_dict["category"] == 1 or item_dict["category"] == 6:
			continue
		tags_found.append(item_dict["name"].replace("_", " ").to_lower())
	tag_search_results_found.emit(tag_query, tags_found)


func request_prio(url: String) -> void:
	priority_requester.request(url, HEADERS)


func on_prio_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var response: Array = []
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		SingletonManager.TagIt.log_message(
			"[sSix API] An error was encountered with the request.\nEngine result code: " + str(result) + "\ne621 response code: " + str(response_code),
			DataManager.LogLevel.WARNING)
		prio_get.emit(response)
		return
	
	var json = JSON.new()
	var error = json.parse(body.get_string_from_utf8())
	
	if error == OK:
		var pre_json = json.get_data()
		if pre_json is Array:
			response = pre_json # Should be Array[Dictionary]
	else:
		SingletonManager.TagIt.log_message(
			"[eSix API] Error parsing response data: " + json.get_error_message(),
			DataManager.LogLevel.ERROR
		)
	
	prio_get.emit(response)


func parse_tag_strength(parse_string: String) -> Dictionary:
	var return_dictionary: Dictionary = {}
	
	# I'm seriously starting to question the logic of whoever
	# designed the e621 API.
	if parse_string.is_empty() or parse_string == "[]":
		return return_dictionary
	
	var tags: Array[String] = []
	var strength: Array[int] = []
	var highest_strength: int = 0
	
	var entry_counter: int = 1
	
	for entry in parse_string.split(" "):
		if entry_counter % 2 == 0: # even pares
			strength.append(int(entry)) 
		else: # Odds impares
			tags.append(entry)
		entry_counter += 1
	
	highest_strength = strength.max()
	
	entry_counter = 0
	
	for strength_value in strength:
		var percent_strength: int = roundi(strength_value * 100 / float(highest_strength))
		
		if not return_dictionary.has(str(percent_strength)):
			return_dictionary[str(percent_strength)] = []
		
		return_dictionary[str(percent_strength)].append(tags[entry_counter])
		entry_counter += 1
	
	return return_dictionary


func format_nested_list(input: String) -> String:
	var output: String = ""
	var open_lists: int = 0
	
	var lines: Array = input.split("\n")
	for line in lines:
		var stripped_line: String = line.strip_edges()
		var level: int = 0
		
		while stripped_line.begins_with("*"):
			level += 1
			stripped_line = stripped_line.substr(1)
		
		if level < open_lists:
			for _n in range(open_lists - level):
				output += "[/ul]" + "\n"
			open_lists = level

		if level > open_lists:
			for _n in range(level - open_lists):
				output += "[ul]\n"
			open_lists = level
			
		output += stripped_line.strip_edges() + "\n"
	
	for _n in open_lists:
		output += "[/ul]"

	return output
