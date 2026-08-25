extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	# collect diamond + star
	var pups={}
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd"): pups[c.shape]=c
	print("shapes present: %s   grab_points=%d" % [str(pups.keys()), m.grab_points.size()])
	for s in ["diamond","star"]:
		if pups.has(s): p.global_position=pups[s].global_position; await _step(3)
	print("collected -> walljump=%s grapple=%s" % [str(p.has_walljump), str(p.has_grapple)])

	# --- GRAPPLE ---
	var gp = m.grab_points[0].global_position
	p.global_position = gp + Vector2(0, 70)   # below the grab point, within range
	p.velocity = Vector2.ZERO
	await _step(2)
	Input.action_press("shoot"); await _step(2); Input.action_release("shoot")
	print("GRAPPLE start: grappling=%s" % str(p.grappling))
	await _step(20)
	print("  after zip: player=(%.0f,%.0f) target=(%.0f,%.0f) grappling=%s" % [p.global_position.x, p.global_position.y, gp.x, gp.y, str(p.grappling)])
	Input.action_press("jump"); await _step(2); Input.action_release("jump")
	print("  jump off: grappling=%s vy=%.0f (want negative)" % [str(p.grappling), p.velocity.y])

	# --- WALL JUMP (press into a wall in air, then jump) ---
	# find a pipe/solid column to hug: scan for a tall solid run
	var wallx = -1; var wally = 0
	for cell in m.terrain.get_used_cells():
		if m.terrain.get_cell_atlas_coords(cell).x == 0:  # ground/pipe solid
			var above = Vector2i(cell.x, cell.y-2)
			if m.terrain.get_cell_source_id(above) >= 0:
				wallx = cell.x; wally = cell.y-2; break
	if wallx >= 0:
		p.has_walljump = true
		p.global_position = Vector2(wallx*16 - 7, wally*16)   # just left of the wall
		p.velocity = Vector2(0, 50)
		Input.action_press("move_right")   # press INTO the wall
		await _step(3)
		print("WALL: wall_dir=%s (want 1)" % str(p.wall_dir))
		Input.action_press("jump"); await _step(2)
		print("WALL JUMP: vy=%.0f (want negative) vx=%.0f (want negative=away)" % [p.velocity.y, p.velocity.x])
		Input.action_release("jump"); Input.action_release("move_right")
	print("DONE"); quit()
