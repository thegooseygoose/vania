extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 16
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	print("pickups: %s" % str(m.powerup_tile_cells.map(func(c): return c[1])))
	p.has_walljump = true; p.has_double_jump = true; p.has_dash = true
	# ---- WALL JUMP SHAFT ----
	p.global_position = Vector2(72*16 + 8, 11*16 - 14); p.velocity = Vector2.ZERO
	for i in range(20): await physics_frame
	var best_y := 9999.0; var jump_on := false; var last := -99; var kick_dir := 1
	for f in range(900):
		Input.action_release("move_left"); Input.action_release("move_right")
		if p.is_on_floor():
			Input.action_press("move_right")
			if not jump_on and f - last > 8: Input.action_press("jump"); jump_on = true; last = f
		elif p.wall_dir != 0:
			kick_dir = -p.wall_dir
			Input.action_press("move_left" if kick_dir < 0 else "move_right")
			if not jump_on and f - last > 6: Input.action_press("jump"); jump_on = true; last = f
		else:
			Input.action_press("move_left" if kick_dir < 0 else "move_right")
		if jump_on and f - last >= 3: Input.action_release("jump"); jump_on = false
		await physics_frame
		best_y = minf(best_y, p.global_position.y)
		if p.global_position.y < 40 and p.global_position.x > 75*16: break
	Input.action_release("move_left"); Input.action_release("move_right"); Input.action_release("jump")
	print("SHAFT: best y=%.0f (ledge stand y~34) end=%s" % [best_y, str(p.global_position)])
	# ---- DASH through the breakable wall at x=90 ----
	p.global_position = Vector2(88*16 + 4, 2*16); p.velocity = Vector2.ZERO
	for i in range(40): await physics_frame
	p.facing = 1
	var solid := func(): return [m.terrain.get_cell_source_id(Vector2i(90,2)), m.terrain.get_cell_source_id(Vector2i(90,1)), m.terrain.get_cell_source_id(Vector2i(90,0))]
	print("before dash: wall cells rows2,1,0 = %s" % str(solid.call()))
	Input.action_press("dash"); await physics_frame; Input.action_release("dash")
	for i in range(30): await physics_frame
	print("after dash: wall cells rows2,1,0 = %s (rows 2&1 gone = doorway, row 0 stays)" % str(solid.call()))
	Input.action_press("move_right")
	for i in range(150): await physics_frame
	Input.action_release("move_right")
	print("walked through: x=%.0f (wall at 1440, goal at 1608)" % p.global_position.x)
	# can the wall be jumped/cleared WITHOUT dash? (reset wall then try wall-jump+double jump from ledge)
	quit()
