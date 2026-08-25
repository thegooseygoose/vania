extends SceneTree
func _snap(n):
	for i in range(4): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/%s.png" % n)
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player
	var bike = null
	for c in m.level.get_children():
		if c.get_script() == load("res://bike.gd"): bike = c

	# build a lava pit with ground shores, mount the bike, drive out over the lava
	var grow := 11
	for c in range(60, 92):
		if c < 66 or c > 85:
			m.terrain.set_cell(Vector2i(c, grow), 0, Vector2i(m.ATLAS_GROUND, 0))   # shores
		else:
			m.terrain.set_cell(Vector2i(c, grow), 0, Vector2i(m.ATLAS_LAVA_TOP, 0)) # lava
			m.terrain.set_cell(Vector2i(c, grow+1), 0, Vector2i(m.ATLAS_LAVA, 0))
	m._collect_lava()

	# idle bike on the left shore
	bike.ridden = false; p.riding = false; p.bike = null
	bike.global_position = Vector2(63*16+8, grow*16 - 8)
	p.global_position = Vector2(70*16, grow*16 - p.col_size.y*0.5 - 60)   # off to the side
	await _step(2)
	await _snap("bike_idle")

	# now ride it out over the lava
	bike.ridden = true; p.riding = true; p.bike = bike
	p.global_position = Vector2(74*16+8, grow*16 - p.col_size.y*0.5)      # mid-lava
	p.velocity = Vector2.ZERO
	await _step(8)
	await _snap("bike_lava")
	print("SNAP bike done -> riding=%s dead=%s" % [str(p.riding), str(p.dead)])
	quit()
