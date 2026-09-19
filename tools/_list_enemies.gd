extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var counts = {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		counts[ax] = counts.get(ax, 0) + 1
	var keys = counts.keys()
	keys.sort()
	for k in keys:
		print("atlas=%d count=%d" % [k, counts[k]])
	quit()
