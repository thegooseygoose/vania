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
	var best_y := 9999.0
	var jump_on := false
	for f in range(900):
		# jump off the floor first, then kick whenever touching a wall
		var want_jump := false
		if p.is_on_floor(): want_jump = true
		elif p.wall_dir != 0: want_jump = true
		if want_jump and not jump_on: Input.action_press("jump"); jump_on = true
		elif jump_on: Input.action_release("jump"); jump_on = false
		# steer toward the wall opposite the one we last touched
		Input.action_release("move_left"); Input.action_release("move_right")
		if p.velocity.x > 0: Input.action_press("move_right")
		elif p.velocity.x < 0: Input.action_press("move_left")
		elif p.wall_dir == 1: Input.action_press("move_left")
		else: Input.action_press("move_right")
		await physics_frame
		best_y = minf(best_y, p.global_position.y)
		if m.game_state != "play": break
	print("best height px y=%.0f (ledge top y=64, goal near x=768) final=%s state=%s" % [best_y, str(p.global_position), m.game_state])
	quit()
