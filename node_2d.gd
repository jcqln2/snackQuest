# Main.gd
extends Node2D

var player_pos = Vector2(100, 400)
var player_speed = 200

func _ready():
	pass

func _process(delta):
	# Handle WASD input
	var velocity = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		velocity.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		velocity.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		velocity.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		velocity.y += 1
	
	# Normalize and apply speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * player_speed
	
	# Update position
	player_pos += velocity * delta
	
	# Keep player on screen
	player_pos.x = clamp(player_pos.x, 0, get_viewport_rect().size.x)
	player_pos.y = clamp(player_pos.y, 0, get_viewport_rect().size.y)
	
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
