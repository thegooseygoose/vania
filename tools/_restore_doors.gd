extends SceneTree
## Restores the doors that got removed, by pulling the original door-tile data from git HEAD's
## Level29.tscn, running the SAME malformed-door fix (95 corrupted L,M,L,M,R runs -> clean L,M,R)
## and the SAME single-orphan removal (78,201)/(79,201) that were already applied earlier this
## session, then writing the corrected door cells into the CURRENT Level29.tscn (which has all the
## other legitimate changes from this session — enemies, colors, morph pickup — kept intact).
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	# 1) load HEAD's original (pre-fix, pre-removal) door layout
	var head_scn = load("res://tools/_Level29_head_doors.tscn").instantiate()
	var head_et = head_scn.get_node("EnemyTiles")
	var cellmap := {}
	for c in head_et.get_used_cells():
		var ax: int = head_et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28:
			cellmap[c] = ax

	# 2) same malformed-run fix as _fix_all_doors.gd: group into maximal same-row consecutive-x
	# runs, trim the leading (len % 3) cells off any run that isn't a clean multiple of 3
	var by_row := {}
	for c in cellmap.keys():
		if not by_row.has(c.y): by_row[c.y] = []
		by_row[c.y].append(c.x)
	var keep := {}   # Vector2i -> atlas value, the FINAL corrected set
	for y in by_row.keys():
		var xs: Array = by_row[y]
		xs.sort()
		var run_start = xs[0]
		var prev = xs[0]
		for i in range(1, xs.size() + 1):
			var cur = xs[i] if i < xs.size() else -9999
			if cur != prev + 1:
				var run_len = prev - run_start + 1
				var trim = run_len % 3
				var kept_start = run_start + trim
				for x in range(kept_start, prev + 1):
					keep[Vector2i(x, y)] = cellmap[Vector2i(x, y)]
				run_start = cur
			prev = cur

	# 3) the single orphan pair removed earlier this session (the very first door fix, near spawn)
	keep.erase(Vector2i(78, 201))
	keep.erase(Vector2i(79, 201))

	print("restoring %d door cells" % keep.size())

	# 4) write into the CURRENT Level29.tscn (keeps every other change made this session)
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	for c in keep.keys():
		et.set_cell(c, 0, Vector2i(keep[c], 0))
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
