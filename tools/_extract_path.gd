extends SceneTree
## Reconstructs the ACTUAL validated path (start -> morph pickup -> double-jump pickup -> goal) from
## the physics-respecting reachability model, with full parent-pointer backtracking (not just "is it
## reachable" — the literal sequence of cells). Writes it to tools/_path_waypoints.csv (x,y pixel
## coords) for a real-engine autopilot to follow step by step, so it never has to guess/beeline
## across the map (and can't blunder into an unrelated chasm the way a straight-line target did).
const W := 480
const H := 450
const JH := 4
var solid := PackedByteArray()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int, m: bool) -> bool:
	return not sol(x, y) and (m or not sol(x, y - 1))
func standable(x: int, y: int, m: bool) -> bool:
	return occ(x, y, m) and sol(x, y + 1)

# BFS from (sx,sy) to target, with morph fixed for this whole search; returns the path as an
# Array of Vector2i (grid cells), or [] if unreachable.
func bfs_path(sx: int, sy: int, target: Vector2i, morph: bool) -> Array:
	var parent := {}   # state_key -> [prev_state_key, x, y]  (store coords too for easy backtrack)
	var seen := {}
	var start_key: int = idx(sx, sy) * 2
	seen[start_key] = true
	parent[start_key] = [-1, sx, sy]
	var q := [[sx, sy, false]]
	var found_key := -1
	while not q.is_empty():
		var s = q.pop_front()   # BFS (FIFO) -> shortest path in state-edges
		var x: int = s[0]; var y: int = s[1]; var usedj: bool = s[2]
		var key: int = idx(x, y) * 2 + (1 if usedj else 0)
		if x == target.x and y == target.y:
			found_key = key
			break
		var grounded: bool = standable(x, y, morph)
		var nbrs := []
		for dx in [-1, 1]:
			var nx: int = x + dx
			if occ(nx, y, morph):
				var ly: int = y
				while not sol(nx, ly + 1) and occ(nx, ly + 1, morph): ly += 1
				if occ(nx, ly, morph): nbrs.append([nx, ly, false])
			if standable(x + dx, y - 1, morph): nbrs.append([x + dx, y - 1, false])
		if not sol(x, y + 1) and occ(x, y + 1, morph):
			var ly2: int = y
			while not sol(x, ly2 + 1) and occ(x, ly2 + 1, morph): ly2 += 1
			nbrs.append([x, ly2, false])
		if grounded:
			for k in range(1, JH + 1):
				if occ(x, y - k, morph): nbrs.append([x, y - k, false])
				else: break
		elif not usedj:
			for k in range(1, JH + 1):
				if occ(x, y - k, morph): nbrs.append([x, y - k, true])
				else: break
		for nb in nbrs:
			var nkey: int = idx(nb[0], nb[1]) * 2 + (1 if nb[2] else 0)
			if not seen.has(nkey):
				seen[nkey] = true
				parent[nkey] = [key, nb[0], nb[1]]
				q.append(nb)
	if found_key == -1:
		return []
	# backtrack
	var path := []
	var k = found_key
	var guard := 0
	while k != -1 and guard < 300000:
		guard += 1
		var entry = parent[k]
		path.append(Vector2i(entry[1], entry[2]))
		k = entry[0]
	path.reverse()
	return path

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and (ax < 45 or ax >= 67):
			solid[idx(c.x, c.y)] = 1
	var mk = scn.get_node("Markers")
	var pw = scn.get_node("Powerups")
	var goal := Vector2i(-9, -9)
	var start_tile := Vector2i(-9, -9)
	for c in mk.get_used_cells():
		var a = mk.get_cell_atlas_coords(c).x
		if a == 19: goal = c
		if a == 18: start_tile = c
	var morph_cell := Vector2i(-9, -9)
	var dj_cell := Vector2i(-9, -9)
	for c in pw.get_used_cells():
		var a = pw.get_cell_atlas_coords(c).x
		if a == 48: morph_cell = c
		if a == 49: dj_cell = c
	var sx: int = start_tile.x; var sy: int = start_tile.y
	while sy < H - 2 and not standable(sx, sy, false): sy += 1
	print("start=(%d,%d) morph=%s dj=%s goal=%s" % [sx, sy, str(morph_cell), str(dj_cell), str(goal)])

	print("stage 1: start -> morph (no abilities)...")
	var p1 := bfs_path(sx, sy, morph_cell, false)
	print("  path length: ", p1.size())
	print("stage 2: morph -> double_jump (morph unlocked)...")
	var p2 := bfs_path(morph_cell.x, morph_cell.y, dj_cell, true)
	print("  path length: ", p2.size())
	print("stage 3: double_jump -> goal (morph unlocked; double-jump modeled via the dj bit already)...")
	var p3 := bfs_path(dj_cell.x, dj_cell.y, goal, true)
	print("  path length: ", p3.size())

	if p1.is_empty() or p2.is_empty() or p3.is_empty():
		print("FAILED to reconstruct one or more stages — see lengths above (0 = unreachable)")
		quit(1)
		return

	var full: Array = p1 + p2.slice(1) + p3.slice(1)   # avoid duplicating the junction cell
	var f := FileAccess.open("res://tools/_path_waypoints.csv", FileAccess.WRITE)
	for c in full:
		f.store_line("%d,%d" % [c.x, c.y])
	f.close()
	print("TOTAL PATH LENGTH: %d cells, saved to tools/_path_waypoints.csv" % full.size())
	quit()
