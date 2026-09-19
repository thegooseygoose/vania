extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax in [26,27,28] and abs(c.x-282)<=6 and abs(c.y-299)<=6:
			print(c, " atlas=", ax)
	quit()
