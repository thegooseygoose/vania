extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	for c in pw.get_used_cells():
		var ax: int = pw.get_cell_atlas_coords(c).x
		if ax == 48:  # morph tile
			print("morph tile at ", c, " dist_from_start=", c.distance_to(Vector2i(40,206)))
	quit()
