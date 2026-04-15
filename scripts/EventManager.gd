class_name EventManager
extends RefCounted

const EVENTS_PATH := "res://data/events.json"

var events: Array[Dictionary] = []
var travel_events: Array[Dictionary] = []

func load_data() -> void:
	var parsed := _load_json_file(EVENTS_PATH)
	events = _as_dictionary_array(parsed.get("events", []))
	travel_events = []
	for event in events:
		if event.get("type", "") == "travel":
			travel_events.append(event)

func get_random_travel_event() -> Dictionary:
	if travel_events.is_empty():
		return {}
	return travel_events[randi() % travel_events.size()]

func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		return parsed
	return {}

func _as_dictionary_array(value: Variant) -> Array[Dictionary]:
	var output: Array[Dictionary] = []
	if value is Array:
		for item in value:
			if item is Dictionary:
				output.append(item)
	return output
