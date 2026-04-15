class_name Ship
extends RefCounted

var capacity: int = 10
var cargo: Dictionary = {}

func _init(initial_capacity: int = 10) -> void:
	capacity = initial_capacity

func get_total_cargo() -> int:
	var total := 0
	for amount in cargo.values():
		total += int(amount)
	return total

func has_space() -> bool:
	return get_total_cargo() < capacity

func add_good(good_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	if get_total_cargo() + amount > capacity:
		return false
	cargo[good_id] = int(cargo.get(good_id, 0)) + amount
	return true

func remove_good(good_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false
	var current := int(cargo.get(good_id, 0))
	if current < amount:
		return false
	current -= amount
	if current == 0:
		cargo.erase(good_id)
	else:
		cargo[good_id] = current
	return true

func get_good_amount(good_id: String) -> int:
	return int(cargo.get(good_id, 0))
