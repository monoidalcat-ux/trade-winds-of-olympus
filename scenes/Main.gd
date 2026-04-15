extends Control

var current_city = "Athens"
var money = 100
var cargo = {}
var cargo_capacity = 10

var goods = ["Olive Oil", "Wine", "Pottery"]

var cities = {
	"Athens": {
		"prices": {
			"Olive Oil": 10,
			"Wine": 14,
			"Pottery": 18
		}
	},
	"Corinth": {
		"prices": {
			"Olive Oil": 15,
			"Wine": 10,
			"Pottery": 20
		}
	},
	"Sparta": {
		"prices": {
			"Olive Oil": 8,
			"Wine": 16,
			"Pottery": 25
		}
	}
}

var selected_good = "Olive Oil"
var selected_destination = "Corinth"
var unlocked_cities = ["Athens", "Corinth", "Sparta"]

@onready var city_label = $CityLabel
@onready var money_label = $MoneyLabel
@onready var cargo_label = $CargoLabel
@onready var log_label = $LogLabel
@onready var prices_label = $PricesLabel

@onready var destination_dropdown = $DestinationDropdown
@onready var goods_dropdown = $GoodsDropdown

func _ready() -> void:
	setup_goods_dropdown()
	setup_destination_dropdown()
	update_ui()

func setup_goods_dropdown() -> void:
	goods_dropdown.clear()

	for good in goods:
		goods_dropdown.add_item(good)

	var index = goods.find(selected_good)
	if index >= 0:
		goods_dropdown.select(index)

func setup_destination_dropdown() -> void:
	destination_dropdown.clear()

	for city in unlocked_cities:
		if city != current_city:
			destination_dropdown.add_item(city)

	if destination_dropdown.item_count > 0:
		destination_dropdown.select(0)
		selected_destination = destination_dropdown.get_item_text(0)
	else:
		selected_destination = current_city

func update_ui() -> void:
	city_label.text = "City: %s" % current_city
	money_label.text = "Money: %d" % money
	cargo_label.text = get_cargo_text()
	prices_label.text = get_prices_text()

	var prices = cities[current_city]["prices"]
	log_label.text = "Selected Good: %s | Price here: %d" % [selected_good, prices[selected_good]]

func get_cargo_text() -> String:
	if cargo.is_empty():
		return "Cargo: Empty"

	var parts = []
	for good in cargo.keys():
		parts.append("%s x%d" % [good, cargo[good]])

	return "Cargo: " + ", ".join(parts)

func get_total_cargo() -> int:
	var total = 0
	for amount in cargo.values():
		total += amount
	return total

func get_prices_text() -> String:
	var prices = cities[current_city]["prices"]
	var lines = ["Prices in %s:" % current_city]

	for good in goods:
		if good == selected_good:
			lines.append("> %s: %d" % [good, prices[good]])
		else:
			lines.append("%s: %d" % [good, prices[good]])

	return "\n".join(lines)

func _on_buy_button_pressed() -> void:
	var price = cities[current_city]["prices"][selected_good]

	if get_total_cargo() >= cargo_capacity:
		log_label.text = "Cargo hold is full."
		return

	if money < price:
		log_label.text = "Not enough money."
		return

	money -= price
	cargo[selected_good] = cargo.get(selected_good, 0) + 1
	log_label.text = "Bought 1 %s in %s for %d." % [selected_good, current_city, price]
	update_ui()

func _on_sell_button_pressed() -> void:
	if cargo.get(selected_good, 0) <= 0:
		log_label.text = "You have no %s to sell." % selected_good
		return

	var price = cities[current_city]["prices"][selected_good]
	cargo[selected_good] -= 1
	money += price

	if cargo[selected_good] <= 0:
		cargo.erase(selected_good)

	log_label.text = "Sold 1 %s in %s for %d." % [selected_good, current_city, price]
	update_ui()

func _on_travel_button_pressed() -> void:
	if destination_dropdown.item_count <= 0:
		log_label.text = "No destination available."
		return

	selected_destination = destination_dropdown.get_item_text(destination_dropdown.selected)

	if selected_destination == current_city:
		log_label.text = "You are already in %s." % current_city
		return

	current_city = selected_destination
	log_label.text = "You sailed to %s." % current_city

	setup_destination_dropdown()
	update_ui()
func _on_goods_dropdown_item_selected(index: int) -> void:
	selected_good = goods_dropdown.get_item_text(index)
	update_ui()

func _on_destination_dropdown_item_selected(index: int) -> void:
	selected_destination = destination_dropdown.get_item_text(index)
	log_label.text = "Destination selected: %s" % selected_destination
