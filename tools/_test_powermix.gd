extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _boot() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 16
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
func _jump_pit(edge_x: float, y: float, double: bool) -> String:
	var p = m.player
	p.global_position = Vector2(edge_x - 40, y); p.velocity = Vector2.ZERO
	for i in range(20): await physics_frame
	Input.action_press("move_right"); Input.action_press("run")
	var jumped := false; var frames := 0; var did2 := false
	for i in range(400):
		await physics_frame
		if not jumped and p.global_position.x >= edge_x - 6:
			Input.action_press("jump"); jumped = true; frames = 0
		if jumped:
			frames += 1
			if frames == 12: Input.action_release("jump")
			if double and frames == 22 and not did2: Input.action_press("jump"); did2 = true
			if double and frames == 28: Input.action_release("jump")
		if jumped and frames > 20 and p.is_on_floor(): break
		if p.global_position.y > 320: break
	Input.action_release("move_right"); Input.action_release("run"); Input.action_release("jump")
	return "x=%.0f y=%.0f floor=%s" % [p.global_position.x, p.global_position.y, str(p.is_on_floor())]
func _run() -> void:
	await _boot()
	var p = m.player
	print("level_file=%d save_stations=%d powerup_tiles=%s" % [m._level_file, m.save_stations.size(), str(m.powerup_tile_cells.size())])
	# pit 1: floor ends at tile 30 (edge px 496), landing floor starts tile 38 (px 608)
	p.has_double_jump = true
	print("PIT1 single jump: ", await _jump_pit(31*16, 13*16 - 14, false), " (should FALL: y>260)")
	m.player.hp = 100
	print("PIT1 double jump: ", await _jump_pit(31*16, 13*16 - 14, true), " (should land x>=608 on floor)")
	# pit 2: floor ends tile 49 (edge px 800), raised platform surface row 11 (y=176) starts tile 57 (px 912)
	print("PIT2 double jump: ", await _jump_pit(50*16, 13*16 - 14, true), " (should land x>=912 y~162)")
	quit()
