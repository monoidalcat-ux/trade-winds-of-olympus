class_name EventManager
extends RefCounted

const EVENTS_PATH := "res://data/events.json"

var events: Array[Dictionary] = []

func load_data() -> void:
	if not FileAccess.file_exists(EVENTS_PATH):
		events = []
		return
	var file := FileAccess.open(EVENTS_PATH, FileAccess.READ)
	if file == null:
		events = []
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if parsed is Dictionary:
		events = parsed.get("events", [])
	else:
		events = []

func get_random_travel_event() -> Dictionary:
	var travel_events: Array[Dictionary] = []
	for event in events:
		if event.get("type", "") == "travel":
			travel_events.append(event)
	if travel_events.is_empty():
		return {}
	return travel_events[randi() % travel_events.size()]
