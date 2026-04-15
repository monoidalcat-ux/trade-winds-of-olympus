extends Control

const DEFAULT_GOOD_ID := "olive_oil"
const WELCOME_MESSAGE := "Welcome, captain."

var city_data := CityData.new()
var game_state := GameState.new()
var event_manager := EventManager.new()

var selected_good_id: String = DEFAULT_GOOD_ID
var selected_destination_id: String = ""
var status_message: String = WELCOME_MESSAGE

@onready var city_label: Label = $CityLabel
@onready var money_label: Label = $MoneyLabel
@onready var cargo_label: Label = $CargoLabel
@onready var log_label: RichTextLabel = $LogLabel
@onready var prices_label: Label = $PricesLabel
@onready var destination_dropdown: OptionButton = $DestinationDropdown
@onready var goods_dropdown: OptionButton = $GoodsDropdown

func _ready() -> void:
	city_data.load_data()
	event_manager.load_data()
	setup_goods_dropdown()
	setup_destination_dropdown()
	update_ui()

func setup_goods_dropdown() -> void:
	goods_dropdown.clear()
	var goods := city_data.get_goods()
	for good in goods:
		goods_dropdown.add_item(good.get("name", "Unknown"))
		goods_dropdown.set_item_metadata(goods_dropdown.item_count - 1, good.get("id", ""))

	for i in range(goods_dropdown.item_count):
		if goods_dropdown.get_item_metadata(i) == selected_good_id:
			goods_dropdown.select(i)
			return
	if goods_dropdown.item_count > 0:
		goods_dropdown.select(0)
		selected_good_id = goods_dropdown.get_item_metadata(0)

func setup_destination_dropdown() -> void:
	destination_dropdown.clear()
	var destinations := game_state.get_available_destinations(city_data)
	for destination_id in destinations:
		destination_dropdown.add_item(city_data.get_city_name(destination_id))
		destination_dropdown.set_item_metadata(destination_dropdown.item_count - 1, destination_id)

	if destination_dropdown.item_count > 0:
		destination_dropdown.select(0)
		selected_destination_id = destination_dropdown.get_item_metadata(0)
	else:
		selected_destination_id = game_state.current_city_id

func update_ui() -> void:
	var city_name := city_data.get_city_name(game_state.current_city_id)
	city_label.text = "City: %s" % city_name
	money_label.text = "Money: %d" % game_state.money
	cargo_label.text = _get_cargo_text()
	prices_label.text = _get_prices_text()
	log_label.text = "%s\nSelected good: %s" % [status_message, city_data.get_good_name(selected_good_id)]

func _get_cargo_text() -> String:
	var cargo := game_state.get_cargo()
	if cargo.is_empty():
		return "Cargo: Empty (0/%d)" % game_state.get_capacity()

	var parts: Array[String] = []
	for good_id in cargo.keys():
		parts.append("%s x%d" % [city_data.get_good_name(good_id), cargo[good_id]])
	return "Cargo (%d/%d): %s" % [game_state.ship.get_total_cargo(), game_state.get_capacity(), ", ".join(parts)]

func _get_prices_text() -> String:
	var lines: Array[String] = ["Prices in %s:" % city_data.get_city_name(game_state.current_city_id)]
	for good in city_data.get_goods():
		var good_id: String = good.get("id", "")
		var price := city_data.get_price(game_state.current_city_id, good_id)
		var prefix := "> " if good_id == selected_good_id else ""
		lines.append("%s%s: %d" % [prefix, good.get("name", good_id), price])
	return "\n".join(lines)

func _on_buy_button_pressed() -> void:
	_apply_action_result(game_state.buy_good(selected_good_id, city_data))

func _on_sell_button_pressed() -> void:
	_apply_action_result(game_state.sell_good(selected_good_id, city_data))

func _on_travel_button_pressed() -> void:
	if destination_dropdown.item_count == 0:
		status_message = "No destination available."
		update_ui()
		return
	selected_destination_id = destination_dropdown.get_item_metadata(destination_dropdown.selected)
	var result := game_state.travel_to(selected_destination_id, city_data)
	status_message = result.get("message", "")
	if result.get("success", false):
		var event := event_manager.get_random_travel_event()
		if not event.is_empty():
			status_message += "\nEvent: %s" % event.get("description", "")
	setup_destination_dropdown()
	update_ui()

func _on_goods_dropdown_item_selected(index: int) -> void:
	selected_good_id = goods_dropdown.get_item_metadata(index)
	status_message = "Selected good: %s" % city_data.get_good_name(selected_good_id)
	update_ui()

func _on_destination_dropdown_item_selected(index: int) -> void:
	selected_destination_id = destination_dropdown.get_item_metadata(index)
	status_message = "Destination selected: %s" % city_data.get_city_name(selected_destination_id)
	update_ui()

func _apply_action_result(result: Dictionary) -> void:
	status_message = result.get("message", "")
	update_ui()
