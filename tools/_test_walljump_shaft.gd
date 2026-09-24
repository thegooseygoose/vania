extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_walljump = true
	p.global_position = Vector2(32*16 + 8, 12*16); p.velocity = Vector2.ZERO
	var best_y := 9999.0; var jump_on := false; var last := -99; var kick_dir := 0
	for f in range(900):
		Input.action_release("move_left"); Input.action_release("move_right")
		if p.is_on_floor():
			Input.action_press("move_left")            # hug the left wall then jump
			if not jump_on and f - last > 8: Input.action_press("jump"); jump_on = true; last = f
		elif p.wall_dir != 0:
			# on a wall: HOLD AWAY and kick across
			kick_dir = -p.wall_dir
			Input.action_press("move_left" if kick_dir < 0 else "move_right")
			if not jump_on and f - last > 6: Input.action_press("jump"); jump_on = true; last = f
		else:
			if kick_dir != 0: Input.action_press("move_left" if kick_dir < 0 else "move_right")
		if jump_on and f - last >= 3: Input.action_release("jump"); jump_on = false
		await physics_frame
		best_y = minf(best_y, p.global_position.y)
		if m.game_state != "play" or p.global_position.y < 50: break
	print("best height px y=%.0f (ledge top y=64) final=%s" % [best_y, str(p.global_position)])
	quit()
