extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _land(p, frames := 300):
	var start_x: float = p.global_position.x
	for i in range(frames):
		await physics_frame
		if i > 10 and p.is_on_floor(): break
	return p.global_position.x - start_x
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_double_jump = true; p.has_morph = true; p.has_boostball = true
	# --- single jump, holding right (no run) ---
	p.global_position = Vector2(2*16, 13*16 - 14); p.velocity = Vector2.ZERO
	for i in range(20): await physics_frame
	Input.action_press("move_right")
	for i in range(30): await physics_frame
	var x0: float = p.global_position.x
	Input.action_press("jump"); await physics_frame
	var apex_y := 9999.0
	var landed := false
	for i in range(200):
		await physics_frame
		apex_y = minf(apex_y, p.global_position.y)
		if i > 8: Input.action_release("jump")
		if i > 10 and p.is_on_floor(): break
	print("SINGLE JUMP: dx=%.0f px (%.1f tiles), apex height=%.0f px" % [p.global_position.x - x0, (p.global_position.x - x0)/16.0, 13*16-14 - apex_y])
	Input.action_release("move_right")
	# --- double jump: jump, then at ~apex press again ---
	p.global_position = Vector2(2*16, 13*16 - 14); p.velocity = Vector2.ZERO
	for i in range(30): await physics_frame
	Input.action_press("move_right")
	for i in range(30): await physics_frame
	x0 = p.global_position.x
	Input.action_press("jump"); await physics_frame
	var did2 := false
	apex_y = 9999.0
	for i in range(300):
		await physics_frame
		apex_y = minf(apex_y, p.global_position.y)
		if i == 4: Input.action_release("jump")
		if i == 30 and not did2: Input.action_press("jump"); did2 = true
		if i == 36: Input.action_release("jump")
		if i > 40 and p.is_on_floor(): break
	print("DOUBLE JUMP: dx=%.0f px (%.1f tiles), apex height=%.0f px" % [p.global_position.x - x0, (p.global_position.x - x0)/16.0, 13*16-14 - apex_y])
	Input.action_release("move_right")
	# --- boost ball from a standstill on the floor, facing right ---
	p.global_position = Vector2(2*16, 13*16 - 8); p.velocity = Vector2.ZERO
	for i in range(20): await physics_frame
	p._enter_morph()
	for i in range(10): await physics_frame
	p.facing = 1
	x0 = p.global_position.x
	var y0: float = p.global_position.y
	Input.action_press("run")
	for i in range(120): await physics_frame     # charge
	Input.action_release("run")
	var miny := y0; var maxdx := 0.0
	for i in range(80):
		await physics_frame
		maxdx = maxf(maxdx, p.global_position.x - x0)
	print("BOOST (level floor): dx=%.0f px (%.1f tiles) boosting_now=%s" % [maxdx, maxdx/16.0, str(p.boosting)])
	quit()
