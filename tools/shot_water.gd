extends SceneTree
## Screenshot the new two-option main menu and a water pool in level 1-1.
func _snap(name: String) -> void:
	for i in range(4): await RenderingServer.frame_post_draw
	var dir := "D:/best game/vania/_shots"
	DirAccess.make_dir_recursive_absolute(dir)
	get_root().get_texture().get_image().save_png("%s/%s.png" % [dir, name])

func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	# ---- 1) the main menu ----
	Main.load_saves()
	var intro = load("res://Intro.tscn").instantiate()
	get_root().add_child(intro)
	await _step(6)
	intro._open_files()          # -> mainmenu
	intro.mm_sel = 0
	await _step(4)
	await _snap("menu_level1")
	intro.mm_sel = 1
	await _step(4)
	await _snap("menu_level2")
	intro.queue_free()
	await _step(4)

	# ---- 2) a water pool in-game ----
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player
	# place the player on the ground, then flood a pool to his right so both fit on screen
	await _step(20)
	var cx := int(floor(p.global_position.x / 16.0))
	var frow := int(floor((p.global_position.y + p.col_size.y * 0.5) / 16.0))   # ground row under feet
	# carve a DEEP pool right where Mario is: remove the ground under him and fill a tall
	# water column (surface crest on top) so he actually sinks into it
	for c in range(cx - 3, cx + 5):
		m.terrain.erase_cell(Vector2i(c, frow))                 # open the floor -> a pit
		m.terrain.set_cell(Vector2i(c, frow - 6), 0, Vector2i(m.ATLAS_WATER_TOP, 0))
		for r in range(frow - 5, frow + 2):
			m.terrain.set_cell(Vector2i(c, r), 0, Vector2i(m.ATLAS_WATER, 0))
	m._collect_water()
	# drop Mario in near the surface, let him sink a bit
	p.global_position = Vector2(cx * 16 + 8, (frow - 5) * 16); p.velocity = Vector2.ZERO
	await _step(14)
	await _snap("water_ingame")
	print("SNAP done -> submerged=%s on_floor=%s" % [str(p.submerged), str(p.is_on_floor())])
	quit()
