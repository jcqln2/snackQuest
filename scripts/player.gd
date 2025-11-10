class_name Player

var position: Vector2
var velocity: Vector2 = Vector2.ZERO
var speed: float
var jump_force: float
var gravity: float
var ground_level: float
var is_on_ground: bool = false
var max_health: float
var health: float
var is_alive: bool = true
var money: int

func _init(initial_position: Vector2, ground_level_value: float, move_speed: float, jump_strength: float, gravity_force: float, max_hp: float, starting_money: int) -> void:
	position = initial_position
	ground_level = ground_level_value
	speed = move_speed
	jump_force = jump_strength
	gravity = gravity_force
	max_health = max_hp
	health = max_hp
	money = starting_money

func reset(initial_position: Vector2, starting_money: int) -> void:
	position = initial_position
	velocity = Vector2.ZERO
	health = max_health
	is_alive = true
	is_on_ground = false
	money = starting_money

func get_horizontal_input() -> int:
	var input := 0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input += 1
	return input

func update_horizontal_velocity(horizontal_input: int) -> void:
	velocity.x = horizontal_input * speed

func attempt_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_ground:
		velocity.y = jump_force
		is_on_ground = false

func apply_physics(delta: float) -> void:
	if not is_on_ground:
		velocity.y += gravity * delta
	position += velocity * delta
	_apply_ground_collision()

func _apply_ground_collision() -> void:
	if position.y >= ground_level:
		position.y = ground_level
		velocity.y = 0
		is_on_ground = true
	else:
		is_on_ground = false

func apply_knockback(knockback_velocity_x: float) -> void:
	velocity.x = knockback_velocity_x

func take_damage(amount: float) -> void:
	health = max(health - amount, 0)
	if health == 0:
		is_alive = false

func heal(amount: float) -> float:
	var previous_health: float = health
	health = min(health + amount, max_health)
	return health - previous_health

func add_money(amount: int) -> void:
	money += amount

func can_afford(cost: int) -> bool:
	return money >= cost

func spend_money(cost: int) -> void:
	money = max(0, money - cost)

func is_health_full() -> bool:
	return is_equal_approx(health, max_health)

func revive() -> void:
	is_alive = true
	health = max_health

