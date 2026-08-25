extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player

	# ---- COLLECT all three by walking onto them ----
	var pups := {}
	for c in m.level.get_children():
		if c.get_script() == load("res://powerup.gd"): pups[c.shape] = c
	for s in ["square", "triangle", "circle"]:
		if pups.has(s):
			p.global_position = pups[s].global_position
			await _step(3)
	print("collected -> double_jump=%s break=%s morph=%s" % [str(p.has_double_jump), str(p.has_break), str(p.has_morph)])

	# ---- SQUARE: double jump (start on the ground) ----
	p.global_position = Vector2(80, 190); p.velocity = Vector2.ZERO
	await _step(10)   # settle onto the ground
	print("  (on_floor before jump = %s)" % str(p.is_on_floor()))
	Input.action_press("jump"); await _step(3); Input.action_release("jump")  # ground jump
	await _step(10)   # rise to near apex, now airborne + falling
	var vy_before = p.velocity.y
	Input.action_press("jump"); await _step(1)   # air (double) jump
	print("DOUBLE JUMP: air_jump_used=%s  vy before=%.0f after=%.0f (after should be strongly NEGATIVE)" % [str(p.air_jump_used), vy_before, p.velocity.y])
	Input.action_release("jump")
	await _step(20)

	# ---- CIRCLE: morph ball ----
	p.global_position = Vector2(80, 200); p.velocity = Vector2.ZERO
	await _step(6)
	Input.action_press("move_down"); await _step(2); Input.action_release("move_down")
	print("MORPH: morphed=%s col_size=%s (expect ~12x12)" % [str(p.morphed), str(p.col_size)])
	await _step(4)
	Input.action_press("move_up"); await _step(2); Input.action_release("move_up")
	print("UNMORPH: morphed=%s col_size=%s" % [str(p.morphed), str(p.col_size)])

	# ---- TRIANGLE: slam-break a brick ----
	# find a brick tile, stand the player above it, slam down
	var brick = null
	for cell in m.terrain.get_used_cells():
		if m.terrain.get_cell_atlas_coords(cell).x == m.ATLAS_BRICK:
			brick = cell; break
	if brick != null:
		p.global_position = Vector2(brick.x * 16 + 8, brick.y * 16 - 40)
		p.velocity = Vector2.ZERO
		await _step(2)
		Input.action_press("move_down"); await _step(2); Input.action_release("move_down")
		await _step(30)
		var still = m.terrain.get_cell_source_id(brick) >= 0
		print("SLAM-BREAK: brick at %s still there? %s (should be false)" % [str(brick), str(still)])
	else:
		print("SLAM-BREAK: no brick found to test")
	print("DONE")
	quit()
