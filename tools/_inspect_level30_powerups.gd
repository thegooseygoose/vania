extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level30.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	var cells = pw.get_used_cells()
	cells.sort_custom(func(a,b): return a.x < b.x)
	for c in cells:
		print("cell=%s atlas=%s" % [c, pw.get_cell_atlas_coords(c)])
	quit()
