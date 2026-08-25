extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=2
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var pu={}
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd"): pu[c.shape]=true
	print("level_num=%d file=%d  LW=%d" % [m.level_num, m._level_file, m.LW])
	print("powerups: %s (want 6)" % str(pu.keys()))
	print("grab_points=%d  door_switches=%d  door_tiles=%d  goal_cells=%d  lava_rects=%d" % [m.grab_points.size(), m.door_switches.size(), m.door_tile_cells.size(), m.goal_cells.size(), m.lava_rects.size()])
	print("player start=(%.0f,%.0f) enemies=%d" % [m.player.global_position.x, m.player.global_position.y, m.enemies.size()])
	print("DONE"); quit()
