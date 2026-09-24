extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_walljump = true
	p.global_position = Vector2(14*16 - 9, 12*16); p.velocity = Vector2.ZERO
	await physics_frame
	Input.action_press("move_right")
	var jump_on := false; var last := -99
	for f in range(200):
		var press: bool = p.is_on_floor() or ((p.wall_dir != 0 or p.wall_coyote > 0.0) and p.velocity.y > -60.0)
		if press and not jump_on and f - last > 6: Input.action_press("jump"); jump_on = true; last = f; print("f%d PRESS y=%.0f x=%.1f vy=%.0f wd=%d co=%.2f" % [f, p.global_position.y, p.global_position.x, p.velocity.y, p.wall_dir, p.wall_coyote])
		elif jump_on and f - last >= 3: Input.action_release("jump"); jump_on = false
		await physics_frame
		if f % 2 == 0 and f > 18 and f < 56: print("  f%d y=%.0f x=%.1f vx=%.0f vy=%.0f wd=%d co=%.2f jh=%s" % [f, p.global_position.y, p.global_position.x, p.velocity.x, p.velocity.y, p.wall_dir, p.wall_coyote, str(p.jump_held)])
	quit()
