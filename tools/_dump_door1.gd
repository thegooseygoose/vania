extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	print("x=70..90, y=195..210 (# solid terrain, L/M/R = door parts, . open)")
	for y in range(195, 211):
		var line := "y=%3d: " % y
		for x in range(75, 105):
			var c := Vector2i(x, y)
			var dax: int = et.get_cell_atlas_coords(c).x if et.get_cell_source_id(c) >= 0 else -1
			var solid: bool = terr.get_cell_source_id(c) >= 0
			if dax == 26: line += "L"
			elif dax == 27: line += "M"
			elif dax == 28: line += "R"
			elif solid: line += "#"
			else: line += "."
		print(line)
	quit()
