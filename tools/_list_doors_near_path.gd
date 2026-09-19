extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var cells = {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28:
			cells[c] = ax
	# group into rows, print sorted by y then x, to find sequences
	var keys = cells.keys()
	keys.sort_custom(func(a,b): return a.y < b.y if a.y != b.y else a.x < b.x)
	print("all door-part cells (grouped by row), atlas 26=L 27=M 28=R:")
	var last_y = -9999
	var line = ""
	for k in keys:
		if k.y != last_y:
			if line != "": print(line)
			line = "y=%d: " % k.y
			last_y = k.y
		line += "(%d:%d) " % [k.x, cells[k]]
	if line != "": print(line)
	quit()
