extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level30.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var mk = scn.get_node("Markers")
	var max_x := 0
	for c in terr.get_used_cells():
		if c.x > max_x: max_x = c.x
	print("terrain max_x=%d" % max_x)
	print("enemy tiles:")
	for c in et.get_used_cells():
		print("  cell=%s atlas=%s" % [c, et.get_cell_atlas_coords(c)])
	print("markers (goal etc):")
	for c in mk.get_used_cells():
		print("  cell=%s atlas=%s" % [c, mk.get_cell_atlas_coords(c)])
	quit()
