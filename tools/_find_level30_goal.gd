extends SceneTree
## Finds the current GOAL (Markers atlas 19) in Level30.tscn and a standable spot just before it.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level30.tscn").instantiate()
	var mk = scn.get_node("Markers")
	var terr = scn.get_node("Terrain")
	var g := Vector2i(-1, -1)
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x == 19:
			g = c
	print("goal=%s" % str(g))
	for y in range(g.y - 4, g.y + 3):
		var row := ""
		for x in range(g.x - 25, g.x + 3):
			row += "#" if is_solid(terr, x, y) else "."
		print("y=%d %s" % [y, row])
	var cands := []
	for x in range(g.x - 25, g.x + 1):
		var y := g.y
		if (not is_solid(terr, x, y)) and (not is_solid(terr, x, y - 1)) and is_solid(terr, x, y + 1):
			cands.append(x)
	print("standable xs at goal row: %s" % [str(cands)])
	quit()

func is_solid(terr, x: int, y: int) -> bool:
	var cell := Vector2i(x, y)
	if terr.get_cell_source_id(cell) == -1:
		return false
	var ax: int = terr.get_cell_atlas_coords(cell).x
	return ax < 45 or (ax >= 69 and ax <= 80)
