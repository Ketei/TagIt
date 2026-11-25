extends Control


# --- Hydrus Endpoints ---
const THUMBNAILS: String = "get_files/thumbnail?file_id="
const SEARCH: String = "get_files/search_files?tags="
const HYDRUS_FILE_ENDPOINT: String = "get_files/file?file_id="

var file_unsaved: bool = false
var image_changed: bool = false
