extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	for x in range(93, 100):
		for y in range(199, 203):
			var solid: bool = terr.get_cell_source_id(Vector2i(x, y)) >= 0
			if solid:
				print("TERRAIN SOLID at (%d,%d) atlas=%d" % [x, y, terr.get_cell_atlas_coords(Vector2i(x,y)).x])
	quit()
