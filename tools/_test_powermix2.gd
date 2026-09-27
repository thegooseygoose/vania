extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 16
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_walljump = true; p.has_double_jump = true; p.has_morph = true; p.has_boostball = true
	# ---- WALL JUMP SHAFT: start on the shaft floor, kick between the walls up to the ledge ----
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
	# ---- BOOST: on the ledge, morph, charge, launch into the breakable wall at x90-91 ----
	p.global_position = Vector2(85*16 + 8, 2*16); p.velocity = Vector2.ZERO
	for i in range(40): await physics_frame
	Input.action_press("move_down"); await physics_frame; Input.action_release("move_down")
	for i in range(15): await physics_frame
	p.facing = 1
	print("before boost: morphed=%s wall cell(90,2) source=%d cell(90,1)=%d" % [str(p.morphed), m.terrain.get_cell_source_id(Vector2i(90,2)), m.terrain.get_cell_source_id(Vector2i(90,1))])
	Input.action_press("run")
	for i in range(40): await physics_frame
	Input.action_release("run")
	for i in range(90): await physics_frame
	print("after boost: player x=%.0f (wall at 1440..1472) cell(90,2)=%d cell(91,2)=%d cell(90,1)=%d" % [p.global_position.x, m.terrain.get_cell_source_id(Vector2i(90,2)), m.terrain.get_cell_source_id(Vector2i(91,2)), m.terrain.get_cell_source_id(Vector2i(90,1))])
	# roll through the tunnel holding right
	Input.action_press("move_right")
	for i in range(90): await physics_frame
	Input.action_release("move_right")
	print("rolled through: x=%.0f (goal marker at x=1608) morphed=%s" % [p.global_position.x, str(p.morphed)])
	quit()
