extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	print("terrain x=90..99, y=197..203:")
	for y in range(197, 204):
		var line = "y=%d: " % y
		for x in range(90, 100):
			var solid: bool = terr.get_cell_source_id(Vector2i(x, y)) >= 0
			line += "#" if solid else "."
		print(line)
	quit()
