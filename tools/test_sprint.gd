extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player

	# --- top speed: walk vs sprint ---
	var speeds := {}
	for use_run in [false, true]:
		p.global_position = Vector2(400*16+8, -20*16); p.velocity = Vector2.ZERO
		await _step(2)
		if use_run: Input.action_press("run")
		Input.action_press("move_right")
		var pk := 0.0
		for i in range(60):
			await physics_frame
			pk = maxf(pk, absf(p.velocity.x))
		Input.action_release("move_right"); Input.action_release("run")
		speeds[use_run] = pk
	print("TOP SPEED  walk=%.1f  SPRINT=%.1f  (sprint should be faster)" % [speeds[false], speeds[true]])

	# --- jump apex WHILE moving: walk-jump vs sprint-jump (should be EQUAL height) ---
	for c in range(490, 520):
		m.terrain.set_cell(Vector2i(c, 20), 0, Vector2i(m.ATLAS_GROUND, 0))
	m._collect_lava()
	var apexes := {}
	for use_run in [false, true]:
		p.global_position = Vector2(495*16+8, 19*16); p.velocity = Vector2.ZERO
		await _step(20)
		# get up to running speed first
		if use_run: Input.action_press("run")
		Input.action_press("move_right")
		await _step(40)
		var y_ground: float = p.global_position.y
		var y_top := y_ground
		Input.action_press("jump")
		for i in range(70):
			await physics_frame
			y_top = minf(y_top, p.global_position.y)
			if p.velocity.y >= 0.0 and i > 3:
				break
		Input.action_release("jump"); Input.action_release("move_right"); Input.action_release("run")
		await _step(20)
		apexes[use_run] = y_ground - y_top
	print("JUMP apex  walk-jump=%.0fpx (%.2f t)  sprint-jump=%.0fpx (%.2f t)  (should MATCH — no bonus height)" % [apexes[false], apexes[false]/16.0, apexes[true], apexes[true]/16.0])
	print("DONE")
	quit()
