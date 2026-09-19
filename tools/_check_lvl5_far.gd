extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level5.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	print("cells x=125..152, all rows, atlas>=60 or otherwise unusual:")
	for c in terr.get_used_cells():
		if c.x >= 125 and c.x <= 155:
			print("  ", c, " atlas=", terr.get_cell_atlas_coords(c).x)
	quit()
