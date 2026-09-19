extends SceneTree
## Prints a clean grid (rows=y, cols=x) of Terrain atlas ids around the Level29 goal so we can
## see the actual standable floor near it. '.' = empty, '#' = solid-ish wall/floor tile, digits=atlas.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var mk = scn.get_node("Markers")
	var terr = scn.get_node("Terrain")
	var g := Vector2i(-1, -1)
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x == 19:
			g = c
	print("goal=%s" % str(g))
	for y in range(g.y - 25, g.y + 5):
		var row := ""
		for x in range(g.x - 40, g.x + 3):
			var cell := Vector2i(x, y)
			if terr.get_cell_source_id(cell) == -1:
				row += "."
			else:
				var ax: int = terr.get_cell_atlas_coords(cell).x
				var solid: bool = ax < 45 or (ax >= 69 and ax <= 80)
				row += "#" if solid else "?"
		print("y=%d %s" % [y, row])
	quit()
