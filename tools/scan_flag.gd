extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(20): await physics_frame
	print("has_flag=%s FLAG_X=%d CASTLE_X=%d" % [str(m.has_flag), m.FLAG_X, m.CASTLE_X])
	# histogram of atlas ids in terrain, and flag/castle-ish tiles
	var hist={}
	for cell in m.terrain.get_used_cells():
		var ax=m.terrain.get_cell_atlas_coords(cell).x
		hist[ax]=hist.get(ax,0)+1
	print("atlas histogram: ", hist)
	# ATLAS_CASTLE=27; look for castle + any tall single-column (flagpole-like)
	print("ATLAS_CASTLE=%d  ATLAS_PIPEUP=%d" % [m.ATLAS_CASTLE, m.ATLAS_PIPEUP])
	for cell in m.terrain.get_used_cells():
		var ax=m.terrain.get_cell_atlas_coords(cell).x
		if ax == m.ATLAS_CASTLE:
			print("  castle tile at ", cell)
	print("DONE"); quit()
