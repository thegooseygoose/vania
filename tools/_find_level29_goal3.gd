extends SceneTree
## Finds standable cells in the final approach corridor before the Level29 goal (a vertical drop
## shaft at x~176, goal at 175,449), to pick a spot for a life-fill station just before the end.

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

	func_dump(terr, g)
	var cands := []
	for x in range(g.x - 45, g.x + 3):
		var y := 432
		if (not is_solid(terr, x, y)) and (not is_solid(terr, x, y - 1)) and is_solid(terr, x, y + 1):
			cands.append(x)
	print("y=432 standable xs: %s" % [str(cands)])
	quit()

func func_dump(terr, g: Vector2i) -> void:
	for y in range(g.y - 26, g.y - 10):
		var row := ""
		for x in range(g.x - 45, g.x + 3):
			var here := is_solid(terr, x, y)
			var below := is_solid(terr, x, y + 1)
			var above := is_solid(terr, x, y - 1)
			if here:
				row += "#"
			elif (not here) and (not above) and below:
				row += "^"   # standable open cell (2 headroom + floor below)
			else:
				row += "."
		print("y=%d %s" % [y, row])

func is_solid(terr, x: int, y: int) -> bool:
	var cell := Vector2i(x, y)
	if terr.get_cell_source_id(cell) == -1:
		return false
	var ax: int = terr.get_cell_atlas_coords(cell).x
	return ax < 45 or (ax >= 69 and ax <= 80)
