class_name CityData
extends RefCounted

const CITIES_PATH := "res://data/cities.json"
const GOODS_PATH := "res://data/goods.json"
const EMPTY_CITY := {}

var cities: Dictionary = {}
var goods: Array[Dictionary] = []

func load_data() -> void:
	var goods_data := _load_json_file(GOODS_PATH)
	var cities_data := _load_json_file(CITIES_PATH)
	goods = _as_dictionary_array(goods_data.get("goods", []))
	cities = cities_data.get("cities", {})

func get_goods() -> Array[Dictionary]:
	return goods

func get_city(city_id: String) -> Dictionary:
	return cities.get(city_id, EMPTY_CITY)

func get_city_name(city_id: String) -> String:
	return get_city(city_id).get("name", city_id.capitalize())

func get_price(city_id: String, good_id: String) -> int:
	return int(get_city(city_id).get("prices", {}).get(good_id, 0))

func get_routes(city_id: String) -> Array:
	return get_city(city_id).get("routes", [])

func get_available_destinations(current_city_id: String, unlocked_city_ids: Array) -> Array:
	var routes: Array = get_routes(current_city_id)
	var destinations: Array[String] = []
	for route in routes:
		if route in unlocked_city_ids and route != current_city_id:
			destinations.append(route)
	return destinations

func get_good_name(good_id: String) -> String:
	for good in goods:
		if good.get("id", "") == good_id:
			return good.get("name", good_id)
	return good_id

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
