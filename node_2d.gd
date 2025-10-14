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
	# Make camera follow player
	$Camera2D.position = player_pos
	
	# Load store image (you need to add an image file to your project)
	# Replace "res://store_interior.png" with your actual image path
	store_image = load("res://inside711.jpg")
	
	# Generate random stars
	for i in range(50):
		stars.append({
			"pos": Vector2(randf_range(-500, 2500), randf_range(20, 250)),
			"speed": randf_range(0.5, 2.0),
			"offset": randf() * PI * 2  # Random phase offset
		})

func _input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_E:
			e_key_pressed = true
		elif event.keycode == KEY_B:
			b_key_pressed = true
		elif event.keycode == KEY_Q:
			q_key_pressed = true

func restart_game():
	# Reset all game variables
	player_pos = Vector2(640, 450)
	player_velocity = Vector2.ZERO
	player_health = 100.0
	is_alive = true
	is_in_store = false
	player_money = 50
	rats.clear()
	rat_spawn_timer = 0.0
	time_passed = 0.0
	$Camera2D.position = player_pos
	print("Game Restarted!")

func _process(delta):
	if !is_alive:
		# Check for restart input
		if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_R):
			restart_game()
		queue_redraw()
		return  # Stop processing if player is dead
	
	# Check if player is in store
	if is_in_store:
		handle_store_input()
		queue_redraw()
		return
		
	time_passed += delta
	rat_spawn_timer += delta
	
	# Check if player is near store entrance
	var dist_to_store = abs(player_pos.x - store_pos.x)
	if dist_to_store < 50 and is_on_ground:
		# Press E to enter store
		if e_key_pressed:
			is_in_store = true
			e_key_pressed = false
			print("Entered 7-Eleven!")
	
	# Spawn rats periodically
	if rat_spawn_timer >= rat_spawn_interval:
		rat_spawn_timer = 0.0
		spawn_rat()
	
	# Update rats
	update_rats(delta)
	
	# Handle horizontal movement (A and D)
	var horizontal_input = 0
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		horizontal_input -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		horizontal_input += 1
	
	# Apply horizontal movement
	player_velocity.x = horizontal_input * player_speed
	
	# Handle jumping (W or Space) - using ui_accept for Space
	if Input.is_action_just_pressed("ui_accept") and is_on_ground:
		player_velocity.y = jump_force
		is_on_ground = false
	
	# Apply gravity
	if !is_on_ground:
		player_velocity.y += gravity * delta
	
	# Update position
	player_pos += player_velocity * delta
	
	# Simple ground collision
	if player_pos.y >= ground_level:
		player_pos.y = ground_level
		player_velocity.y = 0
		is_on_ground = true
	else:
		is_on_ground = false
	
	# Update camera to follow player (with slight offset to see ahead)
	$Camera2D.position.x = player_pos.x
	$Camera2D.position.y = player_pos.y - 50  # Slight upward offset
	
	queue_redraw()

func handle_store_input():
	# Press Q to exit store
	if q_key_pressed:
		is_in_store = false
		q_key_pressed = false
		print("Exited 7-Eleven!")
	
	# Press B to buy Calorie Mate
	if b_key_pressed:
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
	# Spawn rat ahead of player
	var rat = {
		"pos": Vector2(player_pos.x + 800, ground_level),
		"speed": randf_range(80, 120),
		"size": randf_range(1.5, 2.0)  # Larger rats
	}
	rats.append(rat)

func update_rats(delta):
	# Move rats towards player
	for i in range(rats.size() - 1, -1, -1):
		var rat = rats[i]
		rat.pos.x -= rat.speed * delta
		
		# Remove rats that are far behind player
		if rat.pos.x < player_pos.x - 500:
			rats.remove_at(i)
		# Check collision with player
		elif abs(rat.pos.x - player_pos.x) < 25 and abs(rat.pos.y - player_pos.y) < 30:
			if player_pos.y < ground_level - 40:
				# Player jumped over rat
				rats.remove_at(i)
			else:
				# Player got hit - take damage
				player_health -= 25
				player_velocity.x = -150
				print("Hit by rat! Health: ", player_health)
				rats.remove_at(i)
				
				# Check if player died
				if player_health <= 0:
					player_health = 0
					is_alive = false
					print("Game Over!")

func _draw():
	if is_in_store:
		draw_store_interior()
		return
	
	# Draw twinkling stars
	for star in stars:
		var brightness = (sin(time_passed * star.speed + star.offset) + 1) / 2
		brightness = 0.3 + brightness * 0.7  # Keep stars visible, range 0.3 to 1.0
		var star_color = Color(1, 1, 1, brightness)
		
		# Draw star as a small plus shape
		var s = star.pos
		draw_rect(Rect2(s.x - 1, s.y, 2, 1), star_color)
		draw_rect(Rect2(s.x, s.y - 1, 1, 2), star_color)
	
	# Draw 7-Eleven store
	draw_store_exterior()
	
	# Draw rats
	for rat in rats:
		draw_rat(rat.pos, rat.size)
	
	# Draw health bar and money
	draw_hud()
	
	# Draw player sprite (woman character)
	var p = player_pos
	
	# Body (dress/top - pink/red)
	draw_rect(Rect2(p.x - 8, p.y - 20, 16, 25), Color(0.9, 0.3, 0.4))
	
	# Head (skin tone)
	draw_rect(Rect2(p.x - 6, p.y - 30, 12, 12), Color(0.95, 0.8, 0.7))
	
	# Hair (long, dark brown)
	draw_rect(Rect2(p.x - 7, p.y - 34, 14, 6), Color(0.2, 0.1, 0.05))
	# Hair sides (longer)
	draw_rect(Rect2(p.x - 7, p.y - 28, 3, 8), Color(0.2, 0.1, 0.05))
	draw_rect(Rect2(p.x + 4, p.y - 28, 3, 8), Color(0.2, 0.1, 0.05))
	
	# Legs (darker pants/leggings)
	draw_rect(Rect2(p.x - 7, p.y + 5, 5, 12), Color(0.15, 0.15, 0.2))
	draw_rect(Rect2(p.x + 2, p.y + 5, 5, 12), Color(0.15, 0.15, 0.2))
	
	# Shoes (casual - light brown/tan)
	draw_rect(Rect2(p.x - 7, p.y + 17, 6, 4), Color(0.7, 0.5, 0.3))
	draw_rect(Rect2(p.x + 2, p.y + 17, 6, 4), Color(0.7, 0.5, 0.3))
	
	# Draw "GAME OVER" if dead
	if !is_alive:
		# Darken the entire screen
		var cam_pos = $Camera2D.position
		draw_rect(Rect2(cam_pos.x - 640, cam_pos.y - 360, 1280, 720), Color(0, 0, 0, 0.8))
		
		# Draw "YOU DIED" text using rectangles (BIGGER)
		var text_x = cam_pos.x - 250
		var text_y = cam_pos.y - 120
		var letter_scale = 1.8  # Make letters bigger
		
		# Y letter
		draw_rect(Rect2(text_x, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 30 * letter_scale, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y + 25 * letter_scale, 18 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		
		# O letter
		text_x += 75 * letter_scale
		draw_rect(Rect2(text_x, text_y, 40 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x, text_y + 38 * letter_scale, 40 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 28 * letter_scale, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		
		# U letter
		text_x += 70 * letter_scale
		draw_rect(Rect2(text_x, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 28 * letter_scale, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x, text_y + 38 * letter_scale, 40 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		
		# D letter
		text_x += 95 * letter_scale
		draw_rect(Rect2(text_x, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y, 20 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y + 38 * letter_scale, 20 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 32 * letter_scale, text_y + 12 * letter_scale, 12 * letter_scale, 26 * letter_scale), Color(1, 0, 0))
		
		# I letter
		text_x += 70 * letter_scale
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		
		# E letter
		text_x += 55 * letter_scale
		draw_rect(Rect2(text_x, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y, 28 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y + 19 * letter_scale, 25 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y + 38 * letter_scale, 28 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		
		# D letter (second)
		text_x += 70 * letter_scale
		draw_rect(Rect2(text_x, text_y, 12 * letter_scale, 50 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y, 20 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 12 * letter_scale, text_y + 38 * letter_scale, 20 * letter_scale, 12 * letter_scale), Color(1, 0, 0))
		draw_rect(Rect2(text_x + 32 * letter_scale, text_y + 12 * letter_scale, 12 * letter_scale, 26 * letter_scale), Color(1, 0, 0))
		
		# Press R to Restart message (BIGGER BOX)
		var restart_text = cam_pos - Vector2(180, -40)
		draw_rect(Rect2(restart_text.x, restart_text.y, 360, 40), Color(1, 1, 1, 0.9))

func draw_store_exterior():
	var s = store_pos
	
	# Store building (green/teal 7-Eleven colors)
	draw_rect(Rect2(s.x - 80, s.y - 120, 160, 120), Color(0.0, 0.5, 0.4))
	
	# Orange stripe (7-Eleven signature)
	draw_rect(Rect2(s.x - 80, s.y - 100, 160, 15), Color(1.0, 0.4, 0.0))
	
	# Door (brown)
	draw_rect(Rect2(s.x - 20, s.y - 60, 40, 60), Color(0.4, 0.3, 0.2))
	
	# Window
	draw_rect(Rect2(s.x - 70, s.y - 80, 40, 30), Color(0.6, 0.8, 1.0, 0.5))
	draw_rect(Rect2(s.x + 30, s.y - 80, 40, 30), Color(0.6, 0.8, 1.0, 0.5))
	
	# "7-ELEVEN" sign (simplified - just a rectangle)
	draw_rect(Rect2(s.x - 60, s.y - 130, 120, 20), Color(1, 1, 1))
	draw_rect(Rect2(s.x - 55, s.y - 128, 110, 16), Color(0.8, 0.1, 0.1))
	
	# Check if player is near - show prompt
	var dist = abs(player_pos.x - s.x)
	if dist < 50 and is_on_ground:
		var prompt_pos = Vector2(s.x - 40, s.y - 150)
		draw_rect(Rect2(prompt_pos.x, prompt_pos.y, 80, 20), Color(0, 0, 0, 0.8))
		# Simple "PRESS E" text using rectangles
		draw_rect(Rect2(prompt_pos.x + 10, prompt_pos.y + 5, 60, 10), Color(1, 1, 1))

func draw_store_interior():
	var cam_pos = $Camera2D.position
	
	# Draw the store image if loaded
	if store_image:
		# Draw the image centered on screen
		var img_size = store_image.get_size()
		var img_pos = Vector2(cam_pos.x - img_size.x / 2, cam_pos.y - img_size.y / 2)
		draw_texture(store_image, img_pos)
	else:
		# Fallback to drawing rectangles if image not found
		draw_rect(Rect2(cam_pos.x - 640, cam_pos.y - 360, 1280, 720), Color(0.9, 0.9, 0.85))
		draw_rect(Rect2(cam_pos.x - 640, cam_pos.y + 200, 1280, 160), Color(0.7, 0.7, 0.65))
		draw_rect(Rect2(cam_pos.x - 200, cam_pos.y + 50, 400, 80), Color(0.5, 0.3, 0.2))
	
	# UI Panel for store menu
	var ui_x = cam_pos.x - 300
	var ui_y = cam_pos.y - 250
	
	draw_rect(Rect2(ui_x, ui_y, 600, 400), Color(0.1, 0.1, 0.1, 0.95))
	draw_rect(Rect2(ui_x + 5, ui_y + 5, 590, 390), Color(0.2, 0.2, 0.2))
	
	# Title bar
	draw_rect(Rect2(ui_x + 10, ui_y + 10, 580, 40), Color(0.0, 0.5, 0.4))
	draw_rect(Rect2(ui_x + 15, ui_y + 15, 570, 30), Color(0.0, 0.6, 0.5))
	
	# Menu items
	var item_y = ui_y + 70
	
	# Item 1: Calorie Mate
	draw_rect(Rect2(ui_x + 20, item_y, 560, 50), Color(0.3, 0.3, 0.3))
	draw_rect(Rect2(ui_x + 25, item_y + 5, 50, 40), Color(0.9, 0.7, 0.2))
	draw_rect(Rect2(ui_x + 28, item_y + 8, 44, 34), Color(1.0, 0.85, 0.4))
	
	item_y += 60
	
	# Item 2: Onigiri
	draw_rect(Rect2(ui_x + 20, item_y, 560, 50), Color(0.3, 0.3, 0.3))
	draw_rect(Rect2(ui_x + 30, item_y + 10, 30, 30), Color(0.95, 0.95, 0.95))
	draw_rect(Rect2(ui_x + 35, item_y + 25, 20, 10), Color(0.1, 0.1, 0.1))
	
	item_y += 60
	
	# Item 3: Energy Drink
	draw_rect(Rect2(ui_x + 20, item_y, 560, 50), Color(0.3, 0.3, 0.3))
	draw_rect(Rect2(ui_x + 30, item_y + 5, 20, 40), Color(0.2, 0.6, 0.9))
	draw_rect(Rect2(ui_x + 32, item_y + 7, 16, 8), Color(0.8, 0.8, 0.8))
	
	item_y += 70
	
	# Player stats section
	draw_rect(Rect2(ui_x + 20, item_y, 560, 30), Color(0.7, 1.0, 0.7))
	
	item_y += 40
	draw_rect(Rect2(ui_x + 20, item_y, 560, 30), Color(1.0, 1.0, 0.7))
	
	# Instructions at bottom
	item_y += 40
	draw_rect(Rect2(ui_x + 20, item_y, 560, 25), Color(0.9, 0.9, 0.9))

func draw_hud():
	# Draw health bar in top-left of screen (relative to camera)
	var cam_pos = $Camera2D.position
	var bar_x = cam_pos.x - 620
	var bar_y = cam_pos.y - 340
	var bar_width = 200
	var bar_height = 20
	
	# Background (red)
	draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.3, 0, 0))
	
	# Health (green)
	var health_width = (player_health / max_health) * bar_width
	var health_color = Color(0, 1, 0) if player_health > 30 else Color(1, 0.5, 0)
	draw_rect(Rect2(bar_x, bar_y, health_width, bar_height), health_color)
	
	# Border
	draw_rect(Rect2(bar_x, bar_y, bar_width, 2), Color(1, 1, 1))
	draw_rect(Rect2(bar_x, bar_y + bar_height - 2, bar_width, 2), Color(1, 1, 1))
	draw_rect(Rect2(bar_x, bar_y, 2, bar_height), Color(1, 1, 1))
	draw_rect(Rect2(bar_x + bar_width - 2, bar_y, 2, bar_height), Color(1, 1, 1))
	
	# Money display
	var money_y = bar_y + 30
	draw_rect(Rect2(bar_x, money_y, 100, 20), Color(0.2, 0.6, 0.2))
	draw_rect(Rect2(bar_x + 2, money_y + 2, 96, 16), Color(0.3, 0.8, 0.3))

func draw_rat(pos: Vector2, size: float):
	# Draw a pixel art street rat
	var r = pos
	var s = size
	
	# Body (gray-brown)
	draw_rect(Rect2(r.x - 8 * s, r.y - 6 * s, 16 * s, 6 * s), Color(0.4, 0.35, 0.3))
	
	# Head (slightly lighter)
	draw_rect(Rect2(r.x - 10 * s, r.y - 8 * s, 8 * s, 6 * s), Color(0.45, 0.4, 0.35))
	
	# Ears (pink)
	draw_rect(Rect2(r.x - 10 * s, r.y - 10 * s, 3 * s, 3 * s), Color(0.8, 0.5, 0.5))
	draw_rect(Rect2(r.x - 5 * s, r.y - 10 * s, 3 * s, 3 * s), Color(0.8, 0.5, 0.5))
	
	# Tail (long and thin)
	draw_rect(Rect2(r.x + 8 * s, r.y - 4 * s, 10 * s, 2 * s), Color(0.3, 0.25, 0.2))
	
	# Legs
	draw_rect(Rect2(r.x - 6 * s, r.y, 3 * s, 3 * s), Color(0.35, 0.3, 0.25))
	draw_rect(Rect2(r.x + 3 * s, r.y, 3 * s, 3 * s), Color(0.35, 0.3, 0.25))
	
	# Eye (red/glowing)
	draw_rect(Rect2(r.x - 9 * s, r.y - 6 * s, 2 * s, 2 * s), Color(1, 0.2, 0.2))
