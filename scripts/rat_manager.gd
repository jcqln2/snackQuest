class_name RatManager

const PLAYER_GROUND_THRESHOLD := 40.0
const PLAYER_HORIZONTAL_COLLISION_RANGE := 25.0
const PLAYER_VERTICAL_COLLISION_RANGE := 30.0
const PLAYER_KNOCKBACK_X := -150.0
const PLAYER_DAMAGE := 25.0
const RAT_DESPAWN_DISTANCE := 500.0
const RAT_SPAWN_OFFSET_X := 800.0

var rats: Array = []
var spawn_timer: float = 0.0
var spawn_interval: float
var ground_level: float

class Rat:
	var position: Vector2
	var speed: float
	var size: float

	func _init(spawn_position: Vector2, move_speed: float, rat_size: float) -> void:
		position = spawn_position
		speed = move_speed
		size = rat_size

func _init(spawn_interval_seconds: float, ground_level_value: float) -> void:
	spawn_interval = spawn_interval_seconds
	ground_level = ground_level_value

func reset() -> void:
	rats.clear()
	spawn_timer = 0.0

func update(delta: float, player) -> void:
	_update_spawn_timer(delta, player.position)
	_update_rats(delta, player)

func _update_spawn_timer(delta: float, player_position: Vector2) -> void:
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_rat(player_position)

func _spawn_rat(player_position: Vector2) -> void:
	var spawn_position := Vector2(player_position.x + RAT_SPAWN_OFFSET_X, ground_level)
	var speed := randf_range(80.0, 120.0)
	var size := randf_range(1.5, 2.0)
	rats.append(Rat.new(spawn_position, speed, size))

func _update_rats(delta: float, player) -> void:
	for index in range(rats.size() - 1, -1, -1):
		var rat: Rat = rats[index]
		rat.position.x -= rat.speed * delta

		if rat.position.x < player.position.x - RAT_DESPAWN_DISTANCE:
			rats.remove_at(index)
		elif _is_player_colliding(rat, player):
			_handle_collision(index, player)

func _is_player_colliding(rat: Rat, player) -> bool:
	return abs(rat.position.x - player.position.x) < PLAYER_HORIZONTAL_COLLISION_RANGE and abs(rat.position.y - player.position.y) < PLAYER_VERTICAL_COLLISION_RANGE

func _handle_collision(index: int, player) -> void:
	if player.position.y < ground_level - PLAYER_GROUND_THRESHOLD:
		rats.remove_at(index)
	else:
		player.take_damage(PLAYER_DAMAGE)
		player.apply_knockback(PLAYER_KNOCKBACK_X)
		rats.remove_at(index)
	#var rat: Rat = rats[index]
	#if player.position.y < ground_level - PLAYER_GROUND_THRESHOLD:
		#rats.remove_at(index)
	#else:
		#player.take_damage(PLAYER_DAMAGE)
		#player.apply_knockback(PLAYER_KNOCKBACK_X)
		#rats.remove_at(index)
