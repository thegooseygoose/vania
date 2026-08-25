extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player

	# --- top speed WITHOUT run, then WITH run (in open air so no wall) ---
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
	print("TOP SPEED  no-run=%.1f  run-held=%.1f  (should be EQUAL — run gives no boost)" % [speeds[false], speeds[true]])

	# --- jump apex: full held jump vs a quick tap (needs a floor) ---
	# isolated platform in open air
	for c in range(497, 504):
		m.terrain.set_cell(Vector2i(c, 20), 0, Vector2i(m.ATLAS_GROUND, 0))
	m._collect_lava()
	for hold in [true, false]:
		p.global_position = Vector2(500*16+8, 19*16); p.velocity = Vector2.ZERO
		await _step(30)
		var y_ground: float = p.global_position.y
		var y_top := y_ground
		Input.action_press("jump")
		for i in range(60):
			await physics_frame
			y_top = minf(y_top, p.global_position.y)
			if not hold and i == 2:
				Input.action_release("jump")     # quick tap: release after 3 frames
			if p.velocity.y >= 0.0 and i > 3:
				break                             # reached apex
		Input.action_release("jump")
		await _step(20)
		var apex: float = y_ground - y_top
		print("JUMP apex (%s) = %.0f px = %.1f tiles" % ["HOLD" if hold else "TAP", apex, apex/16.0])

	print("DONE")
	quit()
