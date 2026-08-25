extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player
	p.has_break = true
	# find a brick and a ? block
	var brick = null; var qblock = null
	for cell in m.terrain.get_used_cells():
		var ax = m.terrain.get_cell_atlas_coords(cell).x
		if ax == m.ATLAS_BRICK and brick == null: brick = cell
		if ax == m.ATLAS_QUESTION and qblock == null: qblock = cell
	# slam onto the brick
	p.global_position = Vector2(brick.x*16+8, brick.y*16-44); p.velocity = Vector2.ZERO
	await _step(2)
	Input.action_press("move_down"); await _step(1)
	print("SLAM start: slamming=%s ducking=%s vy=%.0f (want vy=520, ducking=false)" % [str(p.slamming), str(p.ducking), p.velocity.y])
	await _step(2); Input.action_release("move_down")
	await _step(30)
	print("brick broken? %s (want true)" % str(m.terrain.get_cell_source_id(brick) < 0))
	# slam onto a ? block — should NOT break
	if qblock != null:
		p.slamming = false; p.has_break = true
		p.global_position = Vector2(qblock.x*16+8, qblock.y*16-44); p.velocity = Vector2.ZERO
		await _step(2)
		Input.action_press("move_down"); await _step(3); Input.action_release("move_down")
		await _step(30)
		print("? block broken? %s (want FALSE)" % str(m.terrain.get_cell_source_id(qblock) < 0))
	print("DONE"); quit()
