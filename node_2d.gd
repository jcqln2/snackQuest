extends Node2D

const Player = preload("res://scripts/player.gd")
const RatManager = preload("res://scripts/rat_manager.gd")
const StoreManager = preload("res://scripts/store_manager.gd")
const WorldManager = preload("res://scripts/world_manager.gd")
const GameRenderer = preload("res://scripts/game_renderer.gd")

enum GameState { MAIN_MENU, PLAYING, PAUSED }

const INITIAL_PLAYER_POSITION := Vector2(640, 450)
const PLAYER_SPEED := 200.0
const JUMP_FORCE := -400.0
const GRAVITY := 980.0
const GROUND_LEVEL := 720.0
const RAT_SPAWN_INTERVAL := 3.0
const STARTING_MONEY := 20
const MAX_HEALTH := 100.0
const MONEY_REWARD := 5
const MONEY_INTERVAL := 1.0
const STORE_POSITION := Vector2(1500.0, GROUND_LEVEL)

var player: Player
var rat_manager: RatManager
var store_manager: StoreManager
var world_manager: WorldManager
var renderer: GameRenderer
var camera: Camera2D

var game_state := GameState.MAIN_MENU
var menu_selected := 0
var money_timer := 0.0
var e_key_pending := false

func _ready() -> void:
	camera = $Camera2D
	renderer = GameRenderer.new()
	renderer.font = ThemeDB.fallback_font
	renderer.store_image = load("res://inside711.jpg")
	_initialize_game_objects()
	reset_game_variables()
	camera.position = Vector2(640, 360)

func _initialize_game_objects() -> void:
	player = Player.new(INITIAL_PLAYER_POSITION, GROUND_LEVEL, PLAYER_SPEED, JUMP_FORCE, GRAVITY, MAX_HEALTH, STARTING_MONEY)
	rat_manager = RatManager.new(RAT_SPAWN_INTERVAL, GROUND_LEVEL)
	store_manager = StoreManager.new(STORE_POSITION)
	world_manager = WorldManager.new(GROUND_LEVEL)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if store_manager.is_in_store:
			store_manager.handle_menu_input(event.keycode, player)
		else:
			match event.keycode:
				KEY_E:
					e_key_pending = true
				KEY_ESCAPE:
					if game_state == GameState.PLAYING:
						pause_game()
					elif game_state == GameState.PAUSED:
						resume_game()
				KEY_UP, KEY_W:
					if game_state == GameState.MAIN_MENU or game_state == GameState.PAUSED:
						menu_selected = 0
				KEY_DOWN, KEY_S:
					if game_state == GameState.MAIN_MENU or game_state == GameState.PAUSED:
						menu_selected = 1
				KEY_ENTER, KEY_SPACE:
					if game_state == GameState.MAIN_MENU:
						handle_main_menu_selection()
					elif game_state == GameState.PAUSED:
						handle_pause_menu_selection()

func restart_game() -> void:
	reset_game_variables()
	camera.position = player.position
	game_state = GameState.PLAYING
	print("Game Restarted!")

func reset_game_variables() -> void:
	player.reset(INITIAL_PLAYER_POSITION, STARTING_MONEY)
	rat_manager.reset()
	store_manager.exit_store(true)
	store_manager.menu_index = 0
	world_manager = WorldManager.new(GROUND_LEVEL)
	money_timer = 0.0
	e_key_pending = false

func pause_game() -> void:
	game_state = GameState.PAUSED
	menu_selected = 0
	print("Game Paused")

func resume_game() -> void:
	game_state = GameState.PLAYING
	print("Game Resumed")

func handle_main_menu_selection() -> void:
	if menu_selected == 0:
		start_game()
	elif menu_selected == 1:
		get_tree().quit()

func handle_pause_menu_selection() -> void:
	if menu_selected == 0:
		resume_game()
	elif menu_selected == 1:
		quit_to_main_menu()

func start_game() -> void:
	reset_game_variables()
	game_state = GameState.PLAYING
	camera.position = player.position
	print("Game Started!")

func quit_to_main_menu() -> void:
	reset_game_variables()
	game_state = GameState.MAIN_MENU
	menu_selected = 0
	camera.position = Vector2(640, 360)
	print("Returned to Main Menu")

func _process(delta: float) -> void:
	if game_state == GameState.MAIN_MENU:
		world_manager.update_stars(delta)
		queue_redraw()
		return

	if game_state == GameState.PAUSED:
		queue_redraw()
		return

	if not player.is_alive:
		handle_game_over_input()
		queue_redraw()
		return

	if store_manager.is_in_store:
		store_manager.update_feedback(delta)
		queue_redraw()
		return

	update_game_logic(delta)
	update_camera()
	queue_redraw()

func handle_game_over_input() -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		restart_game()

func update_game_logic(delta: float) -> void:
	money_timer += delta
	if money_timer >= MONEY_INTERVAL:
		player.add_money(MONEY_REWARD)
		money_timer = 0.0

	world_manager.update_stars(delta)
	world_manager.update_buildings(player.position)
	rat_manager.update(delta, player)
	_handle_player_movement()
	player.apply_physics(delta)
	_handle_store_entry()

func _handle_player_movement() -> void:
	var horizontal_input := player.get_horizontal_input()
	player.update_horizontal_velocity(horizontal_input)
	player.attempt_jump()

func _handle_store_entry() -> void:
	if store_manager.is_in_store:
		return
	if e_key_pending and store_manager.is_player_near_store(player.position, GROUND_LEVEL) and player.is_on_ground:
		store_manager.enter_store()
		e_key_pending = false
		print("Entered 7-Eleven!")

func update_camera() -> void:
	camera.position.x = player.position.x
	camera.position.y = player.position.y - 50.0

func _draw() -> void:
	if game_state == GameState.MAIN_MENU:
		renderer.draw_main_menu(self, world_manager, menu_selected)
		return

	if store_manager.is_in_store:
		renderer.draw_store_interior(self, store_manager, player, camera.position)
		return

	renderer.draw_world(self, world_manager, store_manager, rat_manager, player, camera.position)
	renderer.draw_player(self, player)
	renderer.draw_hud(self, player, camera.position)

	if not player.is_alive:
		renderer.draw_game_over_screen(self, camera.position)

	if game_state == GameState.PAUSED:
		renderer.draw_pause_menu(self, camera.position, menu_selected)
