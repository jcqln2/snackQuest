class_name StoreManager

const FEEDBACK_DURATION := 2.0

class StoreItem:
	var name: String
	var price: int
	var health: int

	func _init(item_name: String, item_price: int, health_amount: int) -> void:
		name = item_name
		price = item_price
		health = health_amount

var store_position: Vector2
var is_in_store: bool = false
var menu_index: int = 0
var items: Array[StoreItem] = []
var purchase_feedback: String = ""
var purchase_feedback_timer: float = 0.0
var purchase_success: bool = false

func _init(store_pos: Vector2) -> void:
	store_position = store_pos
	_initialize_items()

func _initialize_items() -> void:
	items = [
		StoreItem.new("Calorie Mate", 10, 50),
		StoreItem.new("Onigiri", 5, 25),
		StoreItem.new("Energy Drink", 15, 75),
		StoreItem.new("Exit Store", 0, 0)
	]

func enter_store() -> void:
	is_in_store = true
	menu_index = 0
	purchase_feedback = ""
	purchase_feedback_timer = 0.0

func exit_store(silent: bool = false) -> void:
	is_in_store = false
	purchase_feedback = ""
	purchase_feedback_timer = 0.0
	if not silent:
		print("Exited 7-Eleven!")

func is_player_near_store(player_position: Vector2, ground_level: float) -> bool:
	return abs(player_position.x - store_position.x) < 50.0 and player_position.y >= ground_level

func update_feedback(delta: float) -> void:
	if purchase_feedback_timer > 0.0:
		purchase_feedback_timer -= delta
		if purchase_feedback_timer <= 0.0:
			purchase_feedback = ""

func handle_menu_input(keycode: int, player) -> void:
	match keycode:
		KEY_UP, KEY_W:
			menu_index = max(0, menu_index - 1)
		KEY_DOWN, KEY_S:
			menu_index = min(items.size() - 1, menu_index + 1)
		KEY_ENTER, KEY_B:
			_handle_purchase(player)
		KEY_Q, KEY_ESCAPE:
			exit_store()

func _handle_purchase(player) -> void:
	var item: StoreItem = items[menu_index]

	if menu_index == items.size() - 1:
		exit_store()
		return

	if not player.can_afford(item.price):
		_set_feedback("Not enough money!\nNeed $" + str(item.price) + ", have $" + str(player.money), false)
		return

	if player.is_health_full():
		_set_feedback("Health already full!", false)
		return

	player.spend_money(item.price)
	var health_gained: float = player.heal(item.health)
	_set_feedback("Purchased " + item.name + "!\n-$" + str(item.price) + " | +" + str(int(health_gained)) + " HP", true)

func _set_feedback(message: String, success: bool) -> void:
	purchase_success = success
	purchase_feedback = message
	purchase_feedback_timer = FEEDBACK_DURATION
