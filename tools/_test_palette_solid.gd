extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(10): await physics_frame
	if not m.player: print("NO PLAYER"); quit(); return
	# sample _ground_top_at over a handful of cells with the new palette atlases
	var terr = m.terrain
	var found := 0
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if ax >= 69 and found < 5:
			var top = m.player._ground_top_at(c.x*16+8, c.y*16+2.0)
			print("cell ", c, " atlas=", ax, " ground_top_at=", top, " (expect ", c.y*16.0, " if solid)")
			found += 1
		if found >= 5: break
	quit()
