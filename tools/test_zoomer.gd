extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var Enemy = load("res://enemy.gd")

	# --- TEST 1: full-loop crawl around a solid block ---
	for cx in range(500, 506):
		for cy in range(20, 25):
			m.terrain.set_cell(Vector2i(cx, cy), 0, Vector2i(m.ATLAS_GROUND, 0))
	m._collect_lava()
	var z = Enemy.new(); z.main = m; z.kind = "zoomer"
	m.add_child(z); z.spawn(Vector2(502 * 16 + 8, 20 * 16)); z.active = true
	m.enemies.append(z)
	m.cam_x = 500 * 16
	var cells := {}
	for i in range(1400):
		await physics_frame
		z.active = true
		cells[Vector2i(int(floor(z.global_position.x/16)), int(floor(z.global_position.y/16)))] = true
	var top := false; var bot := false; var lft := false; var rgt := false
	for c in cells.keys():
		if c.y == 19: top = true
		if c.y == 25: bot = true
		if c.x == 499: lft = true
		if c.x == 506: rgt = true
	print("TEST1 block loop -> all four sides = ", top and rgt and bot and lft, " (top:%s right:%s bottom:%s left:%s)" % [top,rgt,bot,lft])
	m.enemies.erase(z); z.queue_free()

	# --- TEST 2: ceiling-placed zoomer crawls along the ceiling ---
	# a ceiling: solid row 30, empty below. Paint zoomer on the empty cell (row 31) under it.
	for cx in range(600, 612):
		m.terrain.set_cell(Vector2i(cx, 30), 0, Vector2i(m.ATLAS_GROUND, 0))
	m._collect_lava()
	var zc = Enemy.new(); zc.main = m; zc.kind = "zoomer"
	m.add_child(zc)
	# feet_pos.y = bottom of the painted empty cell (row 31) = 32*16
	zc.spawn(Vector2(606 * 16 + 8, 32 * 16)); zc.active = true
	m.cam_x = 600 * 16
	var minx := 9999; var maxx := -9999; var stuck_ceiling := true
	for i in range(400):
		await physics_frame
		zc.active = true
		var cc := Vector2i(int(floor(zc.global_position.x/16)), int(floor(zc.global_position.y/16)))
		minx = mini(minx, cc.x); maxx = maxi(maxx, cc.x)
		if cc.y != 31: stuck_ceiling = false      # should stay in row 31 (just under the ceiling)
	print("TEST2 ceiling crawl -> moved along ceiling (dx=%d), stayed on ceiling row = %s" % [maxx-minx, stuck_ceiling])
	m.enemies.erase(zc); zc.queue_free()

	# --- TEST 3: only the boomerang kills it (stomp/dash/knock_out do NOT) ---
	var zk = Enemy.new(); zk.main = m; zk.kind = "zoomer"; m.add_child(zk)
	zk.spawn(Vector2(502*16+8, 20*16))
	zk.knock_out(1);  print("TEST3a knock_out (fireball/shell/rider-kick) -> dead = %s (want false)" % zk.dead)
	zk.dash_kill(1);  print("TEST3b dash_kill -> dead = %s (want false)" % zk.dead)
	zk.squish();      print("TEST3c squish (stomp path) -> dead = %s (want false)" % zk.dead)
	zk.boomerang_kill(1); print("TEST3d boomerang_kill -> dead = %s (want true)" % zk.dead)
	print("DONE")
	quit()
