extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var cellmap = {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28:
			cellmap[c] = ax
	# group by row into maximal consecutive-x runs
	var by_row = {}
	for c in cellmap.keys():
		if not by_row.has(c.y): by_row[c.y] = []
		by_row[c.y].append(c.x)
	var malformed = []
	var total_runs = 0
	for y in by_row.keys():
		var xs: Array = by_row[y]
		xs.sort()
		var run_start = xs[0]
		var prev = xs[0]
		for i in range(1, xs.size() + 1):
			var cur = xs[i] if i < xs.size() else -9999
			if cur != prev + 1:
				var run_len = prev - run_start + 1
				total_runs += 1
				if run_len % 3 != 0:
					malformed.append([y, run_start, prev, run_len])
				run_start = cur
			prev = cur
	print("total door runs=%d  malformed(non-multiple-of-3)=%d" % [total_runs, malformed.size()])
	for m in malformed:
		print("  y=%d x=[%d..%d] len=%d" % [m[0], m[1], m[2], m[3]])
	quit()
