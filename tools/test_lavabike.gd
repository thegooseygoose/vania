extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay=0.0; m.fade_alpha=0.0
	var p = m.player
	var bike = null
	for c in m.level.get_children():
		if c.get_script() == load("res://bike.gd"): bike = c

	# build: ground row 12, lava row 11 sitting on it
	for c in range(200, 240):
		m.terrain.set_cell(Vector2i(c, 12), 0, Vector2i(m.ATLAS_GROUND, 0))
		m.terrain.set_cell(Vector2i(c, 11), 0, Vector2i(m.ATLAS_LAVA_TOP, 0))
	m._collect_lava()

	# --- LAVA DEATH off the bike ---
	bike.ridden=false; p.riding=false; p.bike=null; p.dead=false; p.set_collision_mask_value(1,true)
	p.global_position = Vector2(210*16+8, 11*16 - p.col_size.y*0.5 + 6)   # standing in the lava
	await _step(10)
	print("OFF BIKE in lava: dead=%s (want true)" % str(p.dead))

	# reset death
	p.dead=false; p.died_by_pit=false; p.set_collision_mask_value(1,true)

	# --- ON the bike: safe over the SAME lava ---
	bike.ridden=true; p.riding=true; p.bike=bike
	p.global_position = Vector2(214*16+8, 11*16 - p.col_size.y*0.5)
	p.velocity = Vector2.ZERO
	await _step(12)
	print("ON BIKE on lava: dead=%s (want false)" % str(p.dead))

	# --- BIKE SPEED = 1/4 ---
	# drive on a plain ground runway
	for c in range(300, 360):
		m.terrain.set_cell(Vector2i(c, 12), 0, Vector2i(m.ATLAS_GROUND, 0))
	p.global_position = Vector2(305*16+8, 12*16 - p.col_size.y*0.5)
	p.velocity = Vector2.ZERO
	await _step(4)
	Input.action_press("move_right")
	var pk := 0.0
	for i in range(60):
		await physics_frame
		pk = maxf(pk, absf(p.velocity.x))
	Input.action_release("move_right")
	print("BIKE top speed = %.1f (normal 77 -> quarter ~19)  riding=%s" % [pk, str(p.riding)])

	print("DONE")
	quit()
