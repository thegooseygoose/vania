extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var cellmap = {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28:
			cellmap[c] = ax
	var by_row = {}
	for c in cellmap.keys():
		if not by_row.has(c.y): by_row[c.y] = []
		by_row[c.y].append(c.x)
	var fixed := 0
	var suspicious := []
	for y in by_row.keys():
		var xs: Array = by_row[y]
		xs.sort()
		var run_start = xs[0]
		var prev = xs[0]
		for i in range(1, xs.size() + 1):
			var cur = xs[i] if i < xs.size() else -9999
			if cur != prev + 1:
				var run_len = prev - run_start + 1
				if run_len % 3 != 0:
					var trim = run_len % 3
					# verify the KEPT trailing cells (after trimming) alternate 26,27,28 correctly
					var ok = true
					var kept_start = run_start + trim
					var idx = 0
					for x in range(kept_start, prev + 1):
						var expect = [26, 27, 28][idx % 3]
						if cellmap[Vector2i(x, y)] != expect: ok = false
						idx += 1
					if ok:
						for x in range(run_start, kept_start):
							et.erase_cell(Vector2i(x, y))
						fixed += 1
					else:
						suspicious.append([y, run_start, prev, run_len])
				run_start = cur
			prev = cur
	print("fixed=%d suspicious(needs manual look)=%d" % [fixed, suspicious.size()])
	for s in suspicious:
		print("  SUSPICIOUS y=%d x=[%d..%d] len=%d" % [s[0], s[1], s[2], s[3]])
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
