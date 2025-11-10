class_name GameRenderer

var font: Font
var store_image: Texture2D = null

func draw_main_menu(node: Node2D, world_manager, menu_selected: int) -> void:
	var cam_pos := Vector2(640, 360)
	draw_stars(node, world_manager, cam_pos)
	node.draw_rect(Rect2(0, 0, 1280, 720), Color(0, 0, 0, 0.5))
	node.draw_rect(Rect2(cam_pos.x - 300, cam_pos.y - 200, 600, 100), Color(0.1, 0.1, 0.2, 0.9))
	node.draw_rect(Rect2(cam_pos.x - 295, cam_pos.y - 195, 590, 90), Color(0.2, 0.2, 0.3, 0.9))
	_draw_menu_title(node, cam_pos)
	_draw_menu_option(node, cam_pos, "START GAME", 0, 40, menu_selected)
	_draw_menu_option(node, cam_pos, "QUIT", 1, 100, menu_selected)
	_draw_menu_instructions(node, cam_pos)

func draw_world(node: Node2D, world_manager, store_manager, rat_manager, player, camera_position: Vector2) -> void:
	draw_night_sky(node, camera_position)
	draw_stars(node, world_manager, camera_position)
	draw_buildings(node, world_manager, camera_position)
	draw_ground(node, camera_position, world_manager.ground_level)
	draw_store_exterior(node, store_manager, player, world_manager.ground_level)
	draw_rats(node, rat_manager)

func draw_player(node: Node2D, player) -> void:
	var position: Vector2 = player.position
	_draw_player_body(node, position)
	_draw_player_head(node, position)
	_draw_player_hair(node, position)
	_draw_player_legs(node, position)
	_draw_player_shoes(node, position)

func draw_hud(node: Node2D, player, camera_position: Vector2) -> void:
	var cam_pos := camera_position
	_draw_health_bar(node, cam_pos, player.health, player.max_health)
	_draw_money_display(node, cam_pos, player.money)

func draw_game_over_screen(node: Node2D, camera_position: Vector2) -> void:
	node.draw_rect(Rect2(camera_position.x - 640, camera_position.y - 360, 1280, 720), Color(0, 0, 0, 0.8))
	_draw_you_died_text(node, camera_position)
	_draw_restart_prompt(node, camera_position)

func draw_pause_menu(node: Node2D, camera_position: Vector2, menu_selected: int) -> void:
	node.draw_rect(Rect2(camera_position.x - 640, camera_position.y - 360, 1280, 720), Color(0, 0, 0, 0.7))
	node.draw_rect(Rect2(camera_position.x - 200, camera_position.y - 150, 400, 300), Color(0.15, 0.15, 0.2, 0.95))
	node.draw_rect(Rect2(camera_position.x - 195, camera_position.y - 145, 390, 290), Color(0.2, 0.2, 0.3))
	_draw_pause_title(node, camera_position)
	_draw_pause_option(node, camera_position, "RESUME", 0, 0, menu_selected)
	_draw_pause_option(node, camera_position, "QUIT TO MENU", 1, 60, menu_selected)
	_draw_pause_instructions(node, camera_position)

func draw_store_interior(node: Node2D, store_manager, player, camera_position: Vector2) -> void:
	if store_image:
		var img_size: Vector2 = store_image.get_size()
		var img_pos := Vector2(camera_position.x - img_size.x / 2, camera_position.y - img_size.y / 2)
		node.draw_texture(store_image, img_pos)
	else:
		node.draw_rect(Rect2(camera_position.x - 640, camera_position.y - 360, 1280, 720), Color(0.9, 0.9, 0.85))
	_draw_store_menu(node, store_manager, player, camera_position)
	draw_purchase_feedback(node, store_manager, camera_position)

func draw_purchase_feedback(node: Node2D, store_manager, camera_position: Vector2) -> void:
	if store_manager.purchase_feedback_timer <= 0.0:
		return
	var feedback_width := 350.0
	var feedback_height := 100.0
	var border_color: Color = Color(0, 1, 0) if store_manager.purchase_success else Color(1, 0.3, 0.3)
	var bg_color: Color = Color(0, 0.5, 0, 0.95) if store_manager.purchase_success else Color(0.5, 0, 0, 0.95)
	var scale_factor := 1.0
	if store_manager.purchase_feedback_timer > StoreManager.FEEDBACK_DURATION - 0.3:
		var t: float = (StoreManager.FEEDBACK_DURATION - store_manager.purchase_feedback_timer) / 0.3
		scale_factor = 0.5 + (t * 0.5)
	var scaled_width := feedback_width * scale_factor
	var scaled_height := feedback_height * scale_factor
	var scaled_x := camera_position.x - scaled_width / 2.0
	var scaled_y := camera_position.y - scaled_height / 2.0
	node.draw_rect(Rect2(scaled_x - 3.0, scaled_y - 3.0, scaled_width + 6.0, scaled_height + 6.0), border_color)
	node.draw_rect(Rect2(scaled_x, scaled_y, scaled_width, scaled_height), bg_color)
	var lines: PackedStringArray = store_manager.purchase_feedback.split("\n")
	var text_y := scaled_y + 30.0
	for line in lines:
		node.draw_string(font, Vector2(camera_position.x - 150.0, text_y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 1, 1))
		text_y += 25.0

func draw_night_sky(node: Node2D, camera_position: Vector2) -> void:
	var sky_height := 360.0
	var segments := 20
	for i in range(segments):
		var y := camera_position.y - sky_height + (i * sky_height / segments)
		var t: float = float(i) / float(segments)
		var color := Color(0.05 + t * 0.05, 0.05 + t * 0.1, 0.15 + t * 0.15)
		node.draw_rect(Rect2(camera_position.x - 640.0, y, 1280.0, sky_height / segments + 1.0), color)

func draw_ground(node: Node2D, camera_position: Vector2, ground_level: float) -> void:
	node.draw_rect(Rect2(camera_position.x - 640.0, ground_level, 1280.0, 250.0), Color(0.3, 0.3, 0.35))
	var line_spacing := 100
	var start_x := int((camera_position.x - 640.0) / line_spacing) * line_spacing
	for x in range(int(start_x), int(camera_position.x + 640.0), line_spacing):
		node.draw_rect(Rect2(x, ground_level + 10.0, 3.0, 240.0), Color(0.25, 0.25, 0.3))

func draw_buildings(node: Node2D, world_manager, camera_position: Vector2) -> void:
	for building in world_manager.buildings:
		if building.x > camera_position.x - 700.0 and building.x < camera_position.x + 700.0:
			_draw_building(node, building, world_manager.ground_level)

func _draw_building(node: Node2D, building, ground_level: float) -> void:
	var b_x: float = building.x
	var b_width: float = building.width
	var b_height: float = building.height
	var b_y: float = ground_level - b_height
	var building_colors: Array[Color] = [
		Color(0.15, 0.15, 0.2),
		Color(0.2, 0.15, 0.2),
		Color(0.15, 0.2, 0.25)
	]
	var building_color: Color = building_colors[building.building_type]
	node.draw_rect(Rect2(b_x, b_y, b_width, b_height), building_color)
	var window_rows := int(b_height / 30.0)
	var window_cols := int(b_width / 25.0)
	for row in range(window_rows):
		for col in range(window_cols):
			var window_x := b_x + 10.0 + col * 25.0
			var window_y := b_y + 15.0 + row * 30.0
			var window_lit: bool = (randi() % 10) > 3
			var window_color: Color = Color(0.9, 0.9, 0.7, 0.6) if window_lit else Color(0.1, 0.1, 0.15)
			node.draw_rect(Rect2(window_x, window_y, 15.0, 20.0), window_color)

func draw_stars(node: Node2D, world_manager, camera_position: Vector2) -> void:
	for star in world_manager.stars:
		if star.position.x > camera_position.x - 700.0 and star.position.x < camera_position.x + 700.0:
			var brightness: float = world_manager.calculate_star_brightness(star)
			var star_color := Color(1, 1, 1, brightness)
			var pos: Vector2 = star.position
			node.draw_rect(Rect2(pos.x - 1.0, pos.y, 2.0, 1.0), star_color)
			node.draw_rect(Rect2(pos.x, pos.y - 1.0, 1.0, 2.0), star_color)

func draw_store_exterior(node: Node2D, store_manager, player, ground_level: float) -> void:
	var s: Vector2 = store_manager.store_position
	node.draw_rect(Rect2(s.x - 80.0, s.y - 120.0, 160.0, 120.0), Color(0.0, 0.5, 0.4))
	node.draw_rect(Rect2(s.x - 80.0, s.y - 100.0, 160.0, 15.0), Color(1.0, 0.4, 0.0))
	node.draw_rect(Rect2(s.x - 20.0, s.y - 60.0, 40.0, 60.0), Color(0.4, 0.3, 0.2))
	_draw_store_windows(node, s)
	_draw_store_sign(node, s)
	if store_manager.is_player_near_store(player.position, ground_level):
		_draw_store_entrance_prompt(node, s)

func _draw_store_windows(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 70.0, position.y - 80.0, 40.0, 30.0), Color(0.6, 0.8, 1.0, 0.5))
	node.draw_rect(Rect2(position.x + 30.0, position.y - 80.0, 40.0, 30.0), Color(0.6, 0.8, 1.0, 0.5))

func _draw_store_sign(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 60.0, position.y - 130.0, 120.0, 20.0), Color(1, 1, 1))
	node.draw_rect(Rect2(position.x - 55.0, position.y - 128.0, 110.0, 16.0), Color(0.8, 0.1, 0.1))

func _draw_store_entrance_prompt(node: Node2D, position: Vector2) -> void:
	var prompt_pos := Vector2(position.x - 40.0, position.y - 150.0)
	node.draw_rect(Rect2(prompt_pos.x, prompt_pos.y, 80.0, 20.0), Color(0, 0, 0, 0.8))
	node.draw_rect(Rect2(prompt_pos.x + 10.0, prompt_pos.y + 5.0, 60.0, 10.0), Color(1, 1, 1))

func draw_rats(node: Node2D, rat_manager) -> void:
	for rat in rat_manager.rats:
		_draw_rat(node, rat.position, rat.size)

func _draw_rat(node: Node2D, position: Vector2, size: float) -> void:
	node.draw_rect(Rect2(position.x - 8.0 * size, position.y - 6.0 * size, 16.0 * size, 6.0 * size), Color(0.4, 0.35, 0.3))
	node.draw_rect(Rect2(position.x - 10.0 * size, position.y - 8.0 * size, 8.0 * size, 6.0 * size), Color(0.45, 0.4, 0.35))

func _draw_player_body(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 8.0, position.y - 20.0, 16.0, 25.0), Color(0.9, 0.3, 0.4))

func _draw_player_head(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 6.0, position.y - 30.0, 12.0, 12.0), Color(0.95, 0.8, 0.7))

func _draw_player_hair(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 7.0, position.y - 34.0, 14.0, 6.0), Color(0.2, 0.1, 0.05))
	node.draw_rect(Rect2(position.x - 7.0, position.y - 28.0, 3.0, 8.0), Color(0.2, 0.1, 0.05))
	node.draw_rect(Rect2(position.x + 4.0, position.y - 28.0, 3.0, 8.0), Color(0.2, 0.1, 0.05))

func _draw_player_legs(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 7.0, position.y + 5.0, 5.0, 12.0), Color(0.15, 0.15, 0.2))
	node.draw_rect(Rect2(position.x + 2.0, position.y + 5.0, 5.0, 12.0), Color(0.15, 0.15, 0.2))

func _draw_player_shoes(node: Node2D, position: Vector2) -> void:
	node.draw_rect(Rect2(position.x - 7.0, position.y + 17.0, 6.0, 4.0), Color(0.7, 0.5, 0.3))
	node.draw_rect(Rect2(position.x + 2.0, position.y + 17.0, 6.0, 4.0), Color(0.7, 0.5, 0.3))

func _draw_health_bar(node: Node2D, camera_position: Vector2, health: float, max_health: float) -> void:
	var bar_x := camera_position.x - 620.0
	var bar_y := camera_position.y - 340.0
	var bar_width := 200.0
	var bar_height := 20.0
	node.draw_rect(Rect2(bar_x, bar_y, bar_width, bar_height), Color(0.3, 0, 0))
	var health_width := (health / max_health) * bar_width
	var health_color: Color = Color(0, 1, 0) if health > 30.0 else Color(1, 0.5, 0)
	node.draw_rect(Rect2(bar_x, bar_y, health_width, bar_height), health_color)
	_draw_health_bar_border(node, bar_x, bar_y, bar_width, bar_height)

func _draw_health_bar_border(node: Node2D, x: float, y: float, width: float, height: float) -> void:
	node.draw_rect(Rect2(x, y, width, 2.0), Color(1, 1, 1))
	node.draw_rect(Rect2(x, y + height - 2.0, width, 2.0), Color(1, 1, 1))
	node.draw_rect(Rect2(x, y, 2.0, height), Color(1, 1, 1))
	node.draw_rect(Rect2(x + width - 2.0, y, 2.0, height), Color(1, 1, 1))

func _draw_money_display(node: Node2D, camera_position: Vector2, money: int) -> void:
	var bar_x := camera_position.x - 620.0
	var bar_y := camera_position.y - 310.0
	node.draw_rect(Rect2(bar_x, bar_y, 100.0, 20.0), Color(0.2, 0.6, 0.2))
	node.draw_rect(Rect2(bar_x + 2.0, bar_y + 2.0, 96.0, 16.0), Color(0.3, 0.8, 0.3))
	node.draw_string(font, Vector2(bar_x + 10.0, bar_y + 15.0), "Money: $" + str(money), HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(0, 0, 0))

func _draw_menu_title(node: Node2D, camera_position: Vector2) -> void:
	var title_y := camera_position.y - 160.0
	var title_text := "TOKYO NIGHTS"
	var title_x := camera_position.x - 180.0
	node.draw_string(font, Vector2(title_x, title_y + 30.0), title_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 48, Color(1, 0.3, 0.5))

func _draw_menu_option(node: Node2D, camera_position: Vector2, text: String, index: int, y_offset: float, menu_selected: int) -> void:
	var option_y := camera_position.y + y_offset
	var option_x := camera_position.x - 120.0
	var bg_color: Color = Color(0.8, 0.2, 0.3) if menu_selected == index else Color(0.3, 0.3, 0.4)
	var text_color: Color = Color(1, 1, 1) if menu_selected == index else Color(0.7, 0.7, 0.7)
	node.draw_rect(Rect2(option_x, option_y, 240.0, 40.0), bg_color)
	node.draw_rect(Rect2(option_x + 2.0, option_y + 2.0, 236.0, 36.0), bg_color.darkened(0.2))
	node.draw_string(font, Vector2(option_x + 45.0, option_y + 27.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, text_color)
	if menu_selected == index:
		node.draw_rect(Rect2(option_x - 30.0, option_y + 15.0, 20.0, 10.0), Color(1, 0.8, 0))

func _draw_menu_instructions(node: Node2D, camera_position: Vector2) -> void:
	var inst_y := camera_position.y + 200.0
	node.draw_rect(Rect2(camera_position.x - 200.0, inst_y, 400.0, 60.0), Color(0.1, 0.1, 0.1, 0.8))
	node.draw_string(font, Vector2(camera_position.x - 180.0, inst_y + 25.0), "Arrow Keys to Navigate", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1))
	node.draw_string(font, Vector2(camera_position.x - 180.0, inst_y + 45.0), "Enter/Space to Select", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(1, 1, 1))

func _draw_pause_title(node: Node2D, camera_position: Vector2) -> void:
	var title_y := camera_position.y - 100.0
	var title_x := camera_position.x - 60.0
	node.draw_string(font, Vector2(title_x, title_y + 25.0), "PAUSED", HORIZONTAL_ALIGNMENT_LEFT, -1, 42, Color(1, 0.5, 0.2))

func _draw_pause_option(node: Node2D, camera_position: Vector2, text: String, index: int, y_offset: float, menu_selected: int) -> void:
	var option_y := camera_position.y + y_offset
	var option_x := camera_position.x - 150.0
	var bg_color: Color = Color(0.8, 0.4, 0.2) if menu_selected == index else Color(0.3, 0.3, 0.4)
	var text_color: Color = Color(1, 1, 1) if menu_selected == index else Color(0.7, 0.7, 0.7)
	node.draw_rect(Rect2(option_x, option_y, 300.0, 45.0), bg_color)
	node.draw_rect(Rect2(option_x + 2.0, option_y + 2.0, 296.0, 41.0), bg_color.darkened(0.2))
	node.draw_string(font, Vector2(option_x + 60.0, option_y + 30.0), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 24, text_color)
	if menu_selected == index:
		node.draw_rect(Rect2(option_x - 25.0, option_y + 17.0, 18.0, 11.0), Color(1, 1, 0))

func _draw_pause_instructions(node: Node2D, camera_position: Vector2) -> void:
	var inst_y := camera_position.y + 130.0
	node.draw_rect(Rect2(camera_position.x - 180.0, inst_y, 360.0, 40.0), Color(0.1, 0.1, 0.1, 0.9))
	node.draw_string(font, Vector2(camera_position.x - 160.0, inst_y + 25.0), "ESC to Resume • Arrow Keys + Enter to Select", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(1, 1, 1))

func _draw_store_menu(node: Node2D, store_manager, player, camera_position: Vector2) -> void:
	node.draw_rect(Rect2(camera_position.x - 640.0, camera_position.y - 360.0, 1280.0, 720.0), Color(0, 0, 0, 0.6))
	var menu_width := 400.0
	var menu_height := 350.0
	node.draw_rect(Rect2(camera_position.x - menu_width / 2.0, camera_position.y - menu_height / 2.0, menu_width, menu_height), Color(0.15, 0.15, 0.2, 0.95))
	node.draw_rect(Rect2(camera_position.x - menu_width / 2.0 + 5.0, camera_position.y - menu_height / 2.0 + 5.0, menu_width - 10.0, menu_height - 10.0), Color(0.2, 0.2, 0.3))
	node.draw_string(font, Vector2(camera_position.x - 80.0, camera_position.y - 150.0), "7-ELEVEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(0.8, 0.1, 0.1))
	var money_bg_color := Color(0.2, 0.6, 0.2, 0.8)
	if store_manager.purchase_feedback_timer > 0.0 and store_manager.purchase_success:
		var pulse: float = abs(sin(store_manager.purchase_feedback_timer * 10.0))
		money_bg_color = Color(0.2, 0.8, 0.2, 0.8 + pulse * 0.2)
	node.draw_rect(Rect2(camera_position.x - 180.0, camera_position.y - 110.0, 360.0, 30.0), money_bg_color)
	node.draw_string(font, Vector2(camera_position.x - 60.0, camera_position.y - 87.0), "Money: $" + str(player.money), HORIZONTAL_ALIGNMENT_LEFT, -1, 20, Color(1, 1, 1))
	var health_bar_width := 360.0
	var health_bar_height := 15.0
	var health_percentage: float = player.health / player.max_health
	var health_bar_x := camera_position.x - 180.0
	var health_bar_y := camera_position.y - 75.0
	node.draw_rect(Rect2(health_bar_x, health_bar_y, health_bar_width, health_bar_height), Color(0.3, 0, 0))
	node.draw_rect(Rect2(health_bar_x, health_bar_y, health_bar_width * health_percentage, health_bar_height), Color(0, 1, 0))
	node.draw_rect(Rect2(health_bar_x, health_bar_y, health_bar_width, 2.0), Color(1, 1, 1))
	node.draw_rect(Rect2(health_bar_x, health_bar_y + health_bar_height - 2.0, health_bar_width, 2.0), Color(1, 1, 1))
	node.draw_string(font, Vector2(health_bar_x + 5.0, health_bar_y + 12.0), "HP: " + str(int(player.health)) + "/" + str(int(player.max_health)), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(1, 1, 1))
	for i in range(store_manager.items.size()):
		_draw_store_item(node, store_manager, i, camera_position, -30.0 + i * 60.0)
	node.draw_rect(Rect2(camera_position.x - 180.0, camera_position.y + 160.0, 360.0, 30.0), Color(0.1, 0.1, 0.1, 0.9))
	node.draw_string(font, Vector2(camera_position.x - 170.0, camera_position.y + 180.0), "Arrow Keys + B/Enter to Buy • Q/ESC to Exit", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color(1, 1, 1))

#func _draw_store_item(node: Node2D, store_manager, index: int, camera_position: Vector2, y_offset: float) -> void:
	#var item := store_manager.items[index]
	#var item_y := camera_position.y + y_offset
	#var item_x := camera_position.x - 180.0
	#var is_selected: bool = store_manager.menu_index == index
	#var bg_color: Color = Color(0.0, 0.5, 0.4) if is_selected else Color(0.3, 0.3, 0.4)
	#node.draw_rect(Rect2(item_x, item_y, 360.0, 50.0), bg_color)
	#node.draw_rect(Rect2(item_x + 2.0, item_y + 2.0, 356.0, 46.0), bg_color.darkened(0.2))
	#if is_selected:
		#node.draw_rect(Rect2(item_x - 20.0, item_y + 20.0, 15.0, 10.0), Color(1, 0.8, 0))
	#var text_color: Color = Color(1, 1, 1) if is_selected else Color(0.8, 0.8, 0.8)
	#node.draw_string(font, Vector2(item_x + 15.0, item_y + 22.0), item.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, text_color)
	#if index < store_manager.items.size() - 1:
		#node.draw_string(font, Vector2(item_x + 15.0, item_y + 42.0), "$" + str(item.price) + " • +" + str(item.health) + " HP", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.7, 0.9, 0.7))
func _draw_store_item(node: Node2D, store_manager, index: int, camera_position: Vector2, y_offset: float) -> void:
	var item: StoreManager.StoreItem = store_manager.items[index]
	var item_y := camera_position.y + y_offset
	var item_x := camera_position.x - 180.0
	var is_selected: bool = store_manager.menu_index == index
	var bg_color: Color = Color(0.0, 0.5, 0.4) if is_selected else Color(0.3, 0.3, 0.4)
	node.draw_rect(Rect2(item_x, item_y, 360.0, 50.0), bg_color)
	node.draw_rect(Rect2(item_x + 2.0, item_y + 2.0, 356.0, 46.0), bg_color.darkened(0.2))
	if is_selected:
		node.draw_rect(Rect2(item_x - 20.0, item_y + 20.0, 15.0, 10.0), Color(1, 0.8, 0))
	var text_color: Color = Color(1, 1, 1) if is_selected else Color(0.8, 0.8, 0.8)
	node.draw_string(font, Vector2(item_x + 15.0, item_y + 22.0), item.name, HORIZONTAL_ALIGNMENT_LEFT, -1, 20, text_color)
	if index < store_manager.items.size() - 1:
		node.draw_string(font, Vector2(item_x + 15.0, item_y + 42.0), "$" + str(item.price) + " • +" + str(item.health) + " HP", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.7, 0.9, 0.7))

func _draw_you_died_text(node: Node2D, camera_position: Vector2) -> void:
	# Placeholder for stylized "YOU DIED" text drawing omitted for brevity.
	pass

func _draw_restart_prompt(node: Node2D, camera_position: Vector2) -> void:
	var restart_pos := camera_position - Vector2(180.0, -40.0)
	node.draw_rect(Rect2(restart_pos.x, restart_pos.y, 360.0, 40.0), Color(1, 1, 1, 0.9))
