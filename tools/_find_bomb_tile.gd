extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	for c in pw.get_used_cells():
		var ax: int = pw.get_cell_atlas_coords(c).x
		print(c, " atlas=", ax)
	quit()
