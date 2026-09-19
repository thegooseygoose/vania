extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	print("level_file=", m._level_file, " powerup_tile_cells=", m.powerup_tile_cells.size())
	var found := false
	for pc in m.powerup_tile_cells:
		if pc[1] == "longbeam":
			found = true
			print("found longbeam tile at cell=", pc[0])
	print("longbeam tile present: ", found)
	quit()
