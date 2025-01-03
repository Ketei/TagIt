extends Resource


@export var projects: Array[Dictionary] = []




func new_project(id: String, tags: Array[String], image_id: String) -> void:
	projects.append(
		{
		"id": id,
		"tags": tags.duplicate(),
		"image": image_id
		}
	)
