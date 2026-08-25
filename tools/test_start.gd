extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	# paint TWO start tiles (should use only the first)
	m.terrain.set_cell(Vector2i(70,10), m.SOURCE_ID, Vector2i(18,0))
	m.terrain.set_cell(Vector2i(90,8), m.SOURCE_ID, Vector2i(18,0))
	m._spawn_switch_tiles()
	print("_player_start=%s (want first tile feet ~ (70*16+8, 11*16)=(1128,176))" % str(m._player_start))
	print("both start tiles erased? %s %s (want true true)" % [str(m.terrain.get_cell_source_id(Vector2i(70,10))<0), str(m.terrain.get_cell_source_id(Vector2i(90,8))<0)])
	# respawn the player and confirm he lands at the start
	m.player.spawn(m._player_start)
	print("player spawned at (%.0f,%.0f)" % [m.player.global_position.x, m.player.global_position.y])
	print("DONE"); quit()
