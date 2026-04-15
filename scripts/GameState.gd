class_name GameState
extends RefCounted

var current_city_id: String = "athens"
var money: int = 100
var unlocked_city_ids: Array = ["athens", "corinth", "sparta"]
var ship := Ship.new(10)

func get_cargo() -> Dictionary:
	return ship.cargo

func get_capacity() -> int:
	return ship.capacity

func get_available_destinations(city_data: CityData) -> Array:
	return city_data.get_available_destinations(current_city_id, unlocked_city_ids)

func travel_to(destination_city_id: String, city_data: CityData) -> Dictionary:
	if destination_city_id == current_city_id:
		return {"success": false, "message": "You are already there."}
	if destination_city_id not in get_available_destinations(city_data):
		return {"success": false, "message": "That route is unavailable."}
	current_city_id = destination_city_id
	return {"success": true, "message": "You sailed to %s." % city_data.get_city_name(destination_city_id)}

func buy_good(good_id: String, city_data: CityData) -> Dictionary:
	var price := city_data.get_price(current_city_id, good_id)
	if price <= 0:
		return {"success": false, "message": "That good is unavailable here."}
	if money < price:
		return {"success": false, "message": "Not enough money."}
	if not ship.has_space():
		return {"success": false, "message": "Cargo hold is full."}

	money -= price
	ship.add_good(good_id)
	return {"success": true, "message": "Bought 1 unit for %d drachma." % price}

func sell_good(good_id: String, city_data: CityData) -> Dictionary:
	if ship.get_good_amount(good_id) <= 0:
		return {"success": false, "message": "You have none to sell."}
	var price := city_data.get_price(current_city_id, good_id)
	ship.remove_good(good_id)
	money += price
	return {"success": true, "message": "Sold 1 unit for %d drachma." % price}
