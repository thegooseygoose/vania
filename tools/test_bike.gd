extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player

	# find the Bike node + confirm it was wired
	var bike = null
	for c in m.level.get_children():
		if c.get_class() == "Area2D" and c.get_script() == load("res://bike.gd"):
			bike = c
	print("Bike present=%s  main wired=%s" % [str(bike != null), str(bike != null and bike.main == m)])

	# ---- MOUNT: walk into the bike ----
	p.global_position = bike.global_position
	await _step(3)
	print("MOUNT: riding=%s  bike set=%s" % [str(p.riding), str(p.bike == bike)])

	# ---- RIDE OVER LAVA: paint a lava floor, drive across it, don't die/sink ----
	var lrow := 8
	for c in range(120, 140):
		m.terrain.set_cell(Vector2i(c, lrow), 0, Vector2i(m.ATLAS_LAVA_TOP, 0))
	m._collect_lava()
	# place the rider on the lava surface
	p.global_position = Vector2(122*16+8, lrow*16 - p.col_size.y*0.5)
	p.velocity = Vector2.ZERO
	await _step(6)
	var y0: float = p.global_position.y
	Input.action_press("move_right")
	for i in range(30): await physics_frame
	Input.action_release("move_right")
	var drop: float = p.global_position.y - y0
	print("RIDE-LAVA: drove across, drop=%.0f px, on_floor=%s dead=%s riding=%s (expect ~0 drop, alive)" % [
		drop, str(p.is_on_floor()), str(p.dead), str(p.riding)])

	# ---- DISMOUNT: press Down ----
	Input.action_press("move_down"); await _step(1); Input.action_release("move_down")
	await _step(2)
	print("DISMOUNT: riding=%s  bike.ridden=%s (both should be false)" % [str(p.riding), str(bike.ridden)])

	# ---- WITHOUT bike: same lava = falls through (control) ----
	p.global_position = Vector2(130*16+8, lrow*16 - p.col_size.y*0.5)
	p.velocity = Vector2.ZERO
	await _step(20)
	print("NO-BIKE on lava: y-drop below surface=%.0f px on_floor=%s (should sink through, not stand)" % [
		p.global_position.y - (lrow*16 - p.col_size.y*0.5), str(p.is_on_floor())])

	print("DONE")
	quit()
