extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	for p in [Vector2i(167,176), Vector2i(161,180), Vector2i(163,181), Vector2i(168,191)]:
		print(p, " source=", terr.get_cell_source_id(p), " atlas=", terr.get_cell_atlas_coords(p))
	quit()
