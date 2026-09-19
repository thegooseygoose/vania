extends SceneTree
## Re-runs the forward BFS from START but flags every FALL edge (x,y)->(x,ly2) where the origin is
## fwd-only (not bwd-reached) and the destination IS bwd-reached: these are exactly the one-way
## drops where forward crosses into backward's already-covered territory. A drop taller than can be
## climbed back (JH + double-jump, ~8 tiles) at that spot is where a staircase is needed.
const W := 580
const H := 450
const JH := 4
var solid := PackedByteArray()
var bwd := PackedByteArray()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int) -> bool:
	return not sol(x, y)
func standable(x: int, y: int) -> bool:
	return occ(x, y) and sol(x, y + 1)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and (ax < 45 or ax >= 67):
			solid[idx(c.x, c.y)] = 1
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	bwd = fb.get_buffer(W * H); fb.close()

	var mk = scn.get_node("Markers")
	var start_tile := Vector2i(-9, -9)
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x == 18: start_tile = c
	var sx: int = start_tile.x; var sy: int = start_tile.y
	while sy < H - 2 and not standable(sx, sy): sy += 1

	var seen := {}
	var q := [[sx, sy, false]]
	seen[idx(sx, sy) * 2] = true
	var drops := []  # [x, y_origin, y_dest, height]
	while not q.is_empty():
		var s = q.pop_back()
		var x: int = s[0]; var y: int = s[1]; var dj: bool = s[2]
		var grounded: bool = standable(x, y)
		var nbrs := []
		for dx in [-1, 1]:
			var nx: int = x + dx
			if occ(nx, y):
				var ly: int = y
				while not sol(nx, ly + 1) and occ(nx, ly + 1): ly += 1
				if occ(nx, ly): nbrs.append([nx, ly, false, y if ly > y + 1 else -1, nx])
			if standable(x + dx, y - 1): nbrs.append([x + dx, y - 1, false, -1, -1])
		if not sol(x, y + 1) and occ(x, y + 1):
			var ly2: int = y
			while not sol(x, ly2 + 1) and occ(x, ly2 + 1): ly2 += 1
			nbrs.append([x, ly2, false, y, x])
		if grounded:
			for k in range(1, JH + 1):
				if occ(x, y - k): nbrs.append([x, y - k, false, -1, -1])
				else: break
		elif not dj:
			for k in range(1, JH + 1):
				if occ(x, y - k): nbrs.append([x, y - k, true, -1, -1])
				else: break
		for nb in nbrs:
			var nx2: int = nb[0]; var ny2: int = nb[1]; var ndj: bool = nb[2]
			var key: int = idx(nx2, ny2) * 2 + (1 if ndj else 0)
			var is_new := not seen.has(key)
			if is_new:
				seen[key] = true
				q.append([nx2, ny2, ndj])
			# check drop edges (origin y recorded in nb[3], column in nb[4]) regardless of new/old
			if nb[3] >= 0:
				var oy: int = nb[3]; var ox: int = nb[4]
				var origin_bwd: bool = bwd[idx(ox, oy)] == 1
				var dest_bwd: bool = bwd[idx(nx2, ny2)] == 1
				if not origin_bwd and dest_bwd and (ny2 - oy) >= 1:
					drops.append([ox, oy, ny2, ny2 - oy])

	# dedupe by (x, dest) keep max height
	var best := {}
	for d in drops:
		var k := "%d_%d" % [d[0], d[2]]
		if not best.has(k) or best[k][3] < d[3]: best[k] = d
	var uniq := best.values()
	uniq.sort_custom(func(a,b): return a[3] > b[3])
	print("one-way DROP edges (fwd-only origin -> bwd-reached destination), tallest first:")
	print("total drop edges: %d" % uniq.size())
	for i in range(min(200, uniq.size())):
		var d = uniq[i]
		print("  x=%d  origin_y=%d -> dest_y=%d  drop_height=%d" % [d[0], d[1], d[2], d[3]])
	quit()
