extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	for i in range(20): await physics_frame
	print("file=%d on_floor=%s pos=(%.0f,%.0f) terrain=%d enemies=%d bounds=(%.0f..%.0f, %.0f..%.0f)" % [m._level_file, str(m.player.grounded), m.player.global_position.x, m.player.global_position.y, m.terrain.get_used_cells().size(), m.enemies.size(), m.lvl_left, m.lvl_right, m.lvl_top, m.lvl_bottom])
	quit()
