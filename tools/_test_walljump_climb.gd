extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_walljump = true
	# climb the SAME wall (x tile 14-15 spans px 224..256; stand just left of it), holding INTO the wall
	p.global_position = Vector2(14*16 - 9, 12*16); p.velocity = Vector2.ZERO
	await physics_frame
	Input.action_press("move_right")
	var jumps := 0; var best_y := 9999.0; var jump_on := false; var last_press := -99
	for f in range(600):
		var press := false
		if p.is_on_floor() or ((p.wall_dir != 0 or p.wall_coyote > 0.0) and p.velocity.y > -60.0): press = true
		if press and not jump_on and f - last_press > 6:
			Input.action_press("jump"); jump_on = true; last_press = f; jumps += 1
		elif jump_on and f - last_press >= 3:
			Input.action_release("jump"); jump_on = false
		await physics_frame
		best_y = minf(best_y, p.global_position.y)
		if p.global_position.y < 40: break
	Input.action_release("jump"); Input.action_release("move_right")
	print("SAME-WALL CLIMB: presses=%d best y=%.0f (start ~190, wall top y=32) x=%.0f" % [jumps, best_y, p.global_position.x])
	# short hop: tap jump only briefly vs held, measure rise
	quit()
