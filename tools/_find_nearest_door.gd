extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var start := Vector2i(40, 206)
	var doors := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28:
			doors.append([c, ax])
	doors.sort_custom(func(a, b): return a[0].distance_to(start) < b[0].distance_to(start))
	print("nearest 6 door-part cells to start (40,206):")
	for i in range(min(6, doors.size())):
		print("  ", doors[i][0], " atlas=", doors[i][1], " dist=", doors[i][0].distance_to(start))
	quit()
