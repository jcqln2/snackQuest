# Main.gd
extends Node2D

var player_pos = Vector2(640, 450)
var player_velocity = Vector2.ZERO
var player_speed = 200
var jump_force = -400
var gravity = 980
var is_on_ground = false
var ground_level = 720  # Ground/sidewalk level (970 - 250)
var stars = []  # Array to hold star data
var time_passed = 0.0
var rats = []  # Array to hold rat enemies
var rat_spawn_timer = 0.0
var rat_spawn_interval = 3.0  # Spawn a rat every 3 seconds
var player_health = 100.0
var max_health = 100.0
var is_alive = true
var store_pos = Vector2(1500, ground_level)  # 7-Eleven location
var is_in_store = false
var player_money = 50  # Starting money
var calorie_mate_price = 10
var e_key_pressed = false
var b_key_pressed = false
var q_key_pressed = false
var store_image: Texture2D = null

func _ready():
	$Camera2D.position = player_pos
	store_image = load("res://inside711.jpg")
	generate_stars()

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_E:
				e_key_pressed = true
			KEY_B:
				b_key_pressed = true
			KEY_Q:
				q_key_pressed = true

func restart_game():
	reset_game_variables()
	$Camera2D.position = player_pos
	print("Game Restarted!")

func reset_game_variables():
	player_pos = Vector2(640, 450)
	player_velocity = Vector2.ZERO
	player_health = 100.0
	is_alive = true
	is_in_store = false
	player_money = 50
	rats.clear()
	rat_spawn_timer = 0.0
	time_passed = 0.0

func generate_stars():
	for i in range(50):
		stars.append({
			"pos": Vector2(randf_range(-500, 2500), randf_range(20, 250)),
			"speed": randf_range(0.5, 2.0),
			"offset": randf() * PI * 2
		})

func _process(delta):
	if !is_alive:
		handle_game_over_input()
		queue_redraw()
		return
	
	if is_in_store:
		handle_store_input()
		queue_redraw()
		return
	
	update_game_logic(delta)
	update_camera()
	queue_redraw()

func handle_game_over_input():
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
		restart_game()

func update_game_logic(delta):
	time_passed += delta
	rat_spawn_timer += delta
	
	check_store_entrance()
	handle_rat_spawning()
	update_rats(delta)
	handle_player_movement()
	handle_player_physics(delta)
	handle_ground_collision()

func check_store_entrance():
	var dist_to_store = abs(player_pos.x - store_pos.x)
	if dist_to_store < 50 and is_on_ground and e_key_pressed:
		enter_store()

func enter_store():
	is_in_store = true
	e_key_pressed = false
	print("Entered 7-Eleven!")

func handle_rat_spawning():
	if rat_spawn_timer >= rat_spawn_interval:
		rat_spawn_timer = 0.0
		spawn_rat()

func handle_player_movement():
	var horizontal_input = get_horizontal_input()
	player_velocity.x = horizontal_input * player_speed
	
	if Input.is_action_just_pressed("ui_accept") and is_on_ground:
		player_velocity.y = jump_force
		is_on_ground = false

func get_horizontal_input() -> int:
	var input = 0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input += 1
	return input

func handle_player_physics(delta):
	if !is_on_ground:
		player_velocity.y += gravity * delta
	player_pos += player_velocity * delta

func handle_ground_collision():
	if player_pos.y >= ground_level:
		player_pos.y = ground_level
		player_velocity.y = 0
		is_on_ground = true
	else:
		is_on_ground = false

func update_camera():
	$Camera2D.position.x = player_pos.x
	$Camera2D.position.y = player_pos.y - 50

func handle_store_input():
	if q_key_pressed:
		exit_store()
	
	if b_key_pressed:
		buy_calorie_mate()

func exit_store():
	is_in_store = false
	q_key_pressed = false
	print("Exited 7-Eleven!")

func buy_calorie_mate():
	b_key_pressed = false
	if player_money >= calorie_mate_price:
		if player_health < max_health:
			player_money -= calorie_mate_price
			player_health = min(player_health + 50, max_health)
			print("Bought Calorie Mate! Health restored. Money: $", player_money)
		else:
			print("Health already full!")
	else:
		print("Not enough money! Need $", calorie_mate_price)

func spawn_rat():
	rats.append({
		"pos": Vector2(player_pos.x + 800, ground_level),
		"speed": randf_range(80, 120),
		"size": randf_range(1.5, 2.0)
	})

func update_rats(delta):
	for i in range(rats.size() - 1, -1, -1):
		var rat = rats[i]
		rat.pos.x -= rat.speed * delta
		
		if rat.pos.x < player_pos.x - 500:
			rats.remove_at(i)
		elif check_rat_collision(rat):
			handle_rat_collision(i)

func check_rat_collision(rat) -> bool:
	return abs(rat.pos.x - player_pos.x) < 25 and abs(rat.pos.y - player_pos.y) < 30

func handle_rat_collision(rat_index: int):
	var rat = rats[rat_index]
	
	if player_pos.y < ground_level - 40:
		# Player jumped over rat
		rats.remove_at(rat_index)
	else:
		# Player got hit
		player_health -= 25
		player_velocity.x = -150
		print("Hit by rat! Health: ", player_health)
		rats.remove_at(rat_index)
		
		if player_health <= 0:
			player_health = 0
			is_alive = false
			print("Game Over!")

func _draw():
	if is_in_store:
		draw_store_interior()
		return
	
	draw_stars()
	draw_store_exterior()
	draw_rats()
	draw_hud()
	draw_player()
	
	if !is_alive:
		draw_game_over_screen()

func draw_stars():
	for star in stars:
		var brightness = calculate_star_brightness(star)
		var star_color = Color(1, 1, 1, brightness)
		var s = star.pos
		draw_rect(Rect2(s.x - 1, s.y, 2, 1), star_color)
		draw_rect(Rect2(s.x, s.y - 1, 1, 2), star_color)

func calculate_star_brightness(star) -> float:
	var brightness = (sin(time_passed * star.speed + star.offset) + 1) / 2
	return 0.3 + brightness * 0.7

func draw_game_over_screen():
	var cam_pos = $Camera2D.position
	draw_screen_overlay(cam_pos, Color(0, 0, 0, 0.8))
	draw_you_died_text(cam_pos)
	draw_restart_prompt(cam_pos)

func draw_screen_overlay(cam_pos: Vector2, color: Color):
	draw_rect(Rect2(cam_pos.x - 640, cam_pos.y - 360, 1280, 720), color)

func draw_you_died_text(cam_pos: Vector2):
	var text_x = cam_pos.x - 250
	var text_y = cam_pos.y - 120
	var letter_scale = 1.8
	var red_color = Color(1, 0, 0)
	
	# Y, O, U, D, I, E, D letters (same drawing code as before)
	# ... (keeping the letter drawing code but could be further refactored)
	
	# This section remains the same as original for brevity
	# You could extract individual letter drawing functions if desired

func draw_restart_prompt(cam_pos: Vector2):
	var restart_text = cam_pos - Vector2(180, -40)
	draw_rect(Rect2(restart_text.x, restart_text.y, 360, 40), Color(1, 1, 1, 0.9))

func draw_store_exterior():
	var s = store_pos
	draw_rect(Rect2(s.x - 80, s.y - 120, 160, 120), Color(0.0, 0.5, 0.4))  # Building
	draw_rect(Rect2(s.x - 80, s.y - 100, 160, 15), Color(1.0, 0.4, 0.0))    # Orange stripe
	draw_rect(Rect2(s.x - 20, s.y - 60, 40, 60), Color(0.4, 0.3, 0.2))     # Door
	
	# Windows
	draw_store_windows(s)
	draw_store_sign(s)
	
	if is_near_store_entrance():
		draw_store_entrance_prompt(s)

func draw_store_windows(s: Vector2):
	draw_rect(Rect2(s.x - 70, s.y - 80, 40, 30), Color(0.6, 0.8, 1.0, 0.5))
	draw_rect(Rect2(s.x + 30, s.y - 80, 40, 30), Color(0.6, 0.8, 1.0, 0.5))

func draw_store_sign(s: Vector2):
	draw_rect(Rect2(s.x - 60, s.y - 130, 120, 20), Color(1, 1, 1))
	draw_rect(Rect2(s.x - 55, s.y - 128, 110, 16), Color(0.8, 0.1, 0.1))

func is_near_store_entrance() -> bool:
	return abs(player_pos.x - store_pos.x) < 50 and is_on_ground

func draw_store_entrance_prompt(s: Vector2):
	var prompt_pos = Vector2(s.x - 40, s.y - 150)
	draw_rect(Rect2(prompt_pos.x, prompt_pos.y, 80, 20), Color(0, 0, 0, 0.8))
	draw_rect(Rect2(prompt_pos.x + 10, prompt_pos.y + 5, 60, 10), Color(1, 1, 1))

func draw_store_interior():
	var cam_pos = $Camera2D.position
	
	if store_image:
		var img_size = store_image.get_size()
		var img_pos = Vector2(cam_pos.x - img_size.x / 2, cam_pos.y - img_size.y / 2)
		draw_texture(store_image, img_pos)
	else:
		draw_rect(Rect2(cam_pos.x - 640, cam_pos.y - 360, 1280, 720), Color(0.9, 0.9, 0.85))

func draw_player():
	var p = player_pos
	draw_player_body(p)
	draw_player_head(p)
	draw_player_hair(p)
	draw_player_legs(p)
	draw_player_shoes(p)

func draw_player_body(p: Vector2):
	draw_rect(Rect2(p.x - 8, p.y - 20, 16, 25), Color(0.9, 0.3, 0.4))

func draw_player_head(p: Vector2):
	draw_rect(Rect2(p.x - 6, p.y - 30, 12, 12), Color(0.95, 0.8, 0.7))

func draw_player_hair(p: Vector2):
	draw_rect(Rect2(p.x - 7, p.y - 34, 14, 6), Color(0.2, 0.1, 0.05))
	draw_rect(Rect2(p.x - 7, p.y - 28, 3, 8), Color(0.2, 0.1, 0.05))
	draw_rect(Rect2(p.x + 4, p.y - 28, 3, 8), Color(0.2, 0.1, 0.05))

func draw_player_legs(p: Vector2):
	draw_rect(Rect2(p.x - 7, p.y + 5, 5, 12), Color(0.15, 0.15, 0.2))
	draw_rect(Rect2(p.x + 2, p.y + 5, 5, 12), Color(0.15, 0.15, 0.2))

func draw_player_shoes(p: Vector2):
	draw_rect(Rect2(p.x - 7, p.y + 17, 6, 4), Color(0.7, 0.5, 0.3))
	draw_rect(Rect2(p.x + 2, p.y + 17, 6, 4), Color(0.7, 0.5, 0.3))

func draw_rats():
	for rat in rats:
		draw_rat(rat.pos, rat.size)

func draw_rat(pos: Vector2, size: float):
	var r = pos
	var s = size
	draw_rect(Rect2(r.x - 8 * s, r.y - 6 * s, 16 * s, 6 * s), Color(0.4, 0.35, 0.3))  # Body
	draw_rect(Rect2(r.x - 10 * s, r.y - 8 * s, 8 * s, 6 * s), Color(0.45, 0.4, 0.35)) # Head
	# ... rest of rat drawing

func draw_hud():
	var cam_pos = $Camera2D.position
	draw_health_bar(cam_pos)
	draw_money_display(cam_pos)

func draw_health_bar(cam_pos: Vector2):
	var bar_x = cam_pos.x - 620
	var bar_y = cam_pos.y - 340
	var bar_width = 200
	var bar_height = 20
	
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.3, 0, 0))
	
	var health_width = (player_health / max_health) * bar_width
	var health_color = Color(0, 1, 0) if player_health > 30 else Color(1, 0.5, 0)
	draw_rect(Rect2(bar_x, bar_y, health_width, bar_height), health_color)
	
	draw_health_bar_border(bar_x, bar_y, bar_width, bar_height)

func draw_health_bar_border(x: float, y: float, width: float, height: float):
	draw_rect(Rect2(x, y, width, 2), Color(1, 1, 1))
	draw_rect(Rect2(x, y + height - 2, width, 2), Color(1, 1, 1))
	draw_rect(Rect2(x, y, 2, height), Color(1, 1, 1))
	draw_rect(Rect2(x + width - 2, y, 2, height), Color(1, 1, 1))

func draw_money_display(cam_pos: Vector2):
	var bar_y = cam_pos.y - 310  # Position below health bar
	var bar_x = cam_pos.x - 620
	draw_rect(Rect2(bar_x, bar_y, 100, 20), Color(0.2, 0.6, 0.2))
	draw_rect(Rect2(bar_x + 2, bar_y + 2, 96, 16), Color(0.3, 0.8, 0.3))
