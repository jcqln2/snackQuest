class_name WorldManager

const STAR_COUNT := 100
const BUILDING_SPACING := 300.0
const BUILDING_MIN_HEIGHT := 150.0
const BUILDING_MAX_HEIGHT := 300.0
const BUILDING_MIN_WIDTH := 120.0
const BUILDING_MAX_WIDTH := 200.0
const BUILDING_VIEW_DISTANCE := 700.0
const BUILDING_DESPAWN_DISTANCE := 1500.0

class Star:
	var position: Vector2
	var speed: float
	var offset: float

	func _init(pos: Vector2, speed_value: float, offset_value: float) -> void:
		position = pos
		speed = speed_value
		offset = offset_value

class Building:
	var x: float
	var building_type: int
	var height: float
	var width: float

	func _init(x_position: float, b_type: int, b_height: float, b_width: float) -> void:
		x = x_position
		building_type = b_type
		height = b_height
		width = b_width

var ground_level: float
var stars: Array = []
var buildings: Array = []
var building_spawn_x: float = 0.0

func _init(ground_level_value: float) -> void:
	ground_level = ground_level_value
	_generate_stars()
	_generate_initial_buildings()

func _generate_stars() -> void:
	stars.clear()
	for _i in range(STAR_COUNT):
		var position: Vector2 = Vector2(randf_range(-2000.0, 4000.0), randf_range(20.0, 250.0))
		var speed := randf_range(0.5, 2.0)
		var offset := randf() * PI * 2.0
		stars.append(Star.new(position, speed, offset))

func _generate_initial_buildings() -> void:
	buildings.clear()
	building_spawn_x = -1000.0
	while building_spawn_x < 3000.0:
		_spawn_building()

func update_stars(delta: float) -> void:
	for star in stars:
		star.offset += delta * star.speed

func calculate_star_brightness(star: Star) -> float:
	var brightness: float = (sin(star.offset) + 1.0) / 2.0
	return 0.3 + brightness * 0.7

func update_buildings(player_position: Vector2) -> void:
	for index in range(buildings.size() - 1, -1, -1):
		var building: Building = buildings[index]
		if building.x < player_position.x - BUILDING_DESPAWN_DISTANCE:
			buildings.remove_at(index)

	while building_spawn_x < player_position.x + 2000.0:
		_spawn_building()

func _spawn_building() -> void:
	var building_type: int = randi() % 3
	var height := randf_range(BUILDING_MIN_HEIGHT, BUILDING_MAX_HEIGHT)
	var width := randf_range(BUILDING_MIN_WIDTH, BUILDING_MAX_WIDTH)
	buildings.append(Building.new(building_spawn_x, building_type, height, width))
	building_spawn_x += BUILDING_SPACING


