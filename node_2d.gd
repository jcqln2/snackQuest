# Main.gd
extends Node2D

var player_pos = Vector2(100, 400)
var player_velocity = Vector2.ZERO
var player_speed = 200
var jump_force = -400
var gravity = 980
var is_on_ground = false
var ground_level = 500  # Adjust this based on your background

func _ready():
	# Make camera follow player
	$Camera2D.position = player_pos
	
	# Duplicate background for seamless scrolling
	var bg = $Sprite2D
	var bg_width = bg.texture.get_width()
	
	for i in range(3):
		var new_bg = bg.duplicate()
		new_bg.position.x = bg.position.x + bg_width * (i + 1)
		add_child(new_bg)
#func _ready():
	## Make camera follow player
	#$Camera2D.position = player_pos

func _process(delta):
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

func _draw():
	# Draw player sprite (simple pixel character)
	var p = player_pos
	
	# Body (blue suit)
	draw_rect(Rect2(p.x - 8, p.y - 20, 16, 25), Color(0.2, 0.3, 0.8))
	
	# Head (skin tone)
	draw_rect(Rect2(p.x - 6, p.y - 30, 12, 12), Color(0.95, 0.8, 0.7))
	
	# Hair (brown)
	draw_rect(Rect2(p.x - 6, p.y - 34, 12, 5), Color(0.3, 0.2, 0.1))
	
	# Tie (red)
	draw_rect(Rect2(p.x - 2, p.y - 18, 4, 12), Color(0.8, 0.1, 0.1))
	
	# Legs
	draw_rect(Rect2(p.x - 7, p.y + 5, 5, 12), Color(0.2, 0.2, 0.6))
	draw_rect(Rect2(p.x + 2, p.y + 5, 5, 12), Color(0.2, 0.2, 0.6))
	
	# Shoes
	draw_rect(Rect2(p.x - 7, p.y + 17, 6, 4), Color(0.5, 0.1, 0.1))
	draw_rect(Rect2(p.x + 2, p.y + 17, 6, 4), Color(0.5, 0.1, 0.1))
## Main.gd
#extends Node2D
#
#var player_pos = Vector2(100, 400)
#var player_velocity = Vector2.ZERO
#var player_speed = 200
#var jump_force = -400
#var gravity = 980
#var is_on_ground = false
#var ground_level = 500  # Adjust this based on your background
#
#func _ready():
	## Make camera follow player
	#$Camera2D.position = player_pos
#
#func _process(delta):
	## Handle horizontal movement (A and D)
	#var horizontal_input = 0
	#
	#if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		#horizontal_input -= 1
	#if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		#horizontal_input += 1
	#
	## Apply horizontal movement
	#player_velocity.x = horizontal_input * player_speed
	#
	## Handle jumping (W or Space)
	#if (Input.is_action_just_pressed("ui_up") or Input.is_key_just_pressed(KEY_W) or Input.is_key_just_pressed(KEY_SPACE)) and is_on_ground:
		#player_velocity.y = jump_force
		#is_on_ground = false
	#
	## Apply gravity
	#if !is_on_ground:
		#player_velocity.y += gravity * delta
	#
	## Update position
	#player_pos += player_velocity * delta
	#
	## Simple ground collision
	#if player_pos.y >= ground_level:
		#player_pos.y = ground_level
		#player_velocity.y = 0
		#is_on_ground = true
	#else:
		#is_on_ground = false
	#
	## Update camera to follow player (with slight offset to see ahead)
	#$Camera2D.position.x = player_pos.x
	#$Camera2D.position.y = player_pos.y - 50  # Slight upward offset
	#
	#queue_redraw()
#
#func _draw():
	## Draw player sprite (simple pixel character)
	#var p = player_pos
	#
	## Body (blue suit)
	#draw_rect(Rect2(p.x - 8, p.y - 20, 16, 25), Color(0.2, 0.3, 0.8))
	#
	## Head (skin tone)
	#draw_rect(Rect2(p.x - 6, p.y - 30, 12, 12), Color(0.95, 0.8, 0.7))
	#
	## Hair (brown)
	#draw_rect(Rect2(p.x - 6, p.y - 34, 12, 5), Color(0.3, 0.2, 0.1))
	#
	## Tie (red)
	#draw_rect(Rect2(p.x - 2, p.y - 18, 4, 12), Color(0.8, 0.1, 0.1))
	#
	## Legs
	#draw_rect(Rect2(p.x - 7, p.y + 5, 5, 12), Color(0.2, 0.2, 0.6))
	#draw_rect(Rect2(p.x + 2, p.y + 5, 5, 12), Color(0.2, 0.2, 0.6))
	#
	## Shoes
	#draw_rect(Rect2(p.x - 7, p.y + 17, 6, 4), Color(0.5, 0.1, 0.1))
	#draw_rect(Rect2(p.x + 2, p.y + 17, 6, 4), Color(0.5, 0.1, 0.1))
##
##
##
### Main.gd
##extends Node2D
##
##var player_pos = Vector2(100, 400)
##var player_speed = 200
##
##func _ready():
	##pass
##
##func _process(delta):
	### Handle WASD input
	##var velocity = Vector2.ZERO
	##
	##if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		##velocity.x -= 1
	##if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		##velocity.x += 1
	##if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		##velocity.y -= 1
	##if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		##velocity.y += 1
	##
	### Normalize and apply speed
	##if velocity.length() > 0:
		##velocity = velocity.normalized() * player_speed
	##
	### Update position
	##player_pos += velocity * delta
	##
	### Keep player on screen
	##player_pos.x = clamp(player_pos.x, 0, get_viewport_rect().size.x)
	##player_pos.y = clamp(player_pos.y, 0, get_viewport_rect().size.y)
	##
	##queue_redraw()
##
##func _draw():
	### Draw player sprite (simple pixel character)
	##var p = player_pos
	##
	### Body (blue suit)
	##draw_rect(Rect2(p.x - 8, p.y - 20, 16, 25), Color(0.2, 0.3, 0.8))
	##
	### Head (skin tone)
	##draw_rect(Rect2(p.x - 6, p.y - 30, 12, 12), Color(0.95, 0.8, 0.7))
	##
	### Hair (brown)
	##draw_rect(Rect2(p.x - 6, p.y - 34, 12, 5), Color(0.3, 0.2, 0.1))
	##
	### Tie (red)
	##draw_rect(Rect2(p.x - 2, p.y - 18, 4, 12), Color(0.8, 0.1, 0.1))
	##
	### Legs
	##draw_rect(Rect2(p.x - 7, p.y + 5, 5, 12), Color(0.2, 0.2, 0.6))
	##draw_rect(Rect2(p.x + 2, p.y + 5, 5, 12), Color(0.2, 0.2, 0.6))
	##
	### Shoes
	##draw_rect(Rect2(p.x - 7, p.y + 17, 6, 4), Color(0.5, 0.1, 0.1))
	##draw_rect(Rect2(p.x + 2, p.y + 17, 6, 4), Color(0.5, 0.1, 0.1))
