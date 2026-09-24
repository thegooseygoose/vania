extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_walljump = true
	# stand hugging the slide wall (left edge px 224) mid-air, hold INTO it, do ONE climb hop, measure max gap
	p.global_position = Vector2(224 - 6, 6*16); p.velocity = Vector2.ZERO
	Input.action_press("move_right")
	for i in range(15): await physics_frame
	var wall_x: float = p.global_position.x
	Input.action_press("jump")
	var maxgap := 0.0
	for i in range(50):
		await physics_frame
		maxgap = maxf(maxgap, wall_x - p.global_position.x)
		if i == 2: Input.action_release("jump")
	Input.action_release("move_right")
	print("CLIMB HOP: hugging x=%.1f, max distance off the wall = %.1f px" % [wall_x, maxgap])
	quit()
