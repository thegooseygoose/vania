extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	print("level_file=", m._level_file, " has_walljump=", m.player.has_walljump)
	var p = m.player
	# 1) no power-up: fall beside the slide wall (x=14 tile => wall left edge px 224) and check slide + no kick
	p.global_position = Vector2(14*16 - 9, 5*16); p.velocity = Vector2.ZERO
	Input.action_press("move_right")
	var maxvy := 0.0
	for i in range(40):
		await physics_frame
		maxvy = maxf(maxvy, p.velocity.y)
	print("NO POWERUP: wall_dir=%d max fall vy=%.1f (cap 40)" % [p.wall_dir, maxvy])
	Input.action_press("jump"); await physics_frame; await physics_frame
	print("NO POWERUP after jump press: vx=%.1f vy=%.1f (no kick expected)" % [p.velocity.x, p.velocity.y])
	Input.action_release("jump"); Input.action_release("move_right")
	# 2) with the power-up: kick away
	p.has_walljump = true
	p.global_position = Vector2(14*16 - 9, 5*16); p.velocity = Vector2.ZERO
	Input.action_press("move_right")
	for i in range(20): await physics_frame
	Input.action_press("jump")
	await physics_frame; await physics_frame
	print("WITH POWERUP after jump press: vx=%.1f vy=%.1f (kick away, up)" % [p.velocity.x, p.velocity.y])
	Input.action_release("jump"); Input.action_release("move_right")
	quit()
