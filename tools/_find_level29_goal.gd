extends SceneTree
## Reports the current GOAL (Markers atlas 19) cell(s) in Level29.tscn plus nearby terrain,
## so a life-station placement script can pick a safe spot just before it.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var mk = scn.get_node("Markers")
	var terr = scn.get_node("Terrain")
	var goals := []
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x == 19:
			goals.append(c)
	print("GOAL cells: %s" % [str(goals)])
	for g in goals:
		print("--- around goal %s ---" % str(g))
		for dx in range(-30, 3):
			var col := []
			for dy in range(-20, 20):
				var cell := Vector2i(g.x + dx, g.y + dy)
				var ax: int = terr.get_cell_atlas_coords(cell).x
				col.append(ax if terr.get_cell_source_id(cell) != -1 else -1)
			print("x=%d: %s" % [g.x + dx, str(col)])
	quit()
