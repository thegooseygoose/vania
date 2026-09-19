extends SceneTree
## General physics-reachability BFS (morph=true globally, per memory/vania-level29-realdoors.md's
## "Physics reachability model"). Runs from FROM_ATLAS (18=start marker cell, 19=goal marker cell)
## and dumps the reached PackedByteArray to res://tools/_reach_<tag>.raw for a diff tool to compare.
## Run: Godot --headless --path . -s tools/_bfs_general.gd -- <18|19> <tag>

const W := 580
const H := 450
const JH := 4
var solid := PackedByteArray()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int) -> bool:
	return not sol(x, y)  # morph=true globally -> only need the 1 cell clear
func standable(x: int, y: int) -> bool:
	return occ(x, y) and sol(x, y + 1)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var from_atlas: int = int(args[0]) if args.size() > 0 else 18
	var tag: String = args[1] if args.size() > 1 else "fwd"

	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and (terr.get_cell_atlas_coords(c).x < 45 or terr.get_cell_atlas_coords(c).x >= 67):
			solid[idx(c.x, c.y)] = 1
	var mk = scn.get_node("Markers")
	var from_tile := Vector2i(-9, -9)
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x == from_atlas: from_tile = c
	var sx: int = from_tile.x; var sy: int = from_tile.y
	while sy < H - 2 and not standable(sx, sy): sy += 1

	var seen := {}
	var q := [[sx, sy, false]]
	seen[(idx(sx, sy) * 2)] = true
	var reach := PackedByteArray(); reach.resize(W * H)
	reach[idx(sx, sy)] = 1
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
				if occ(nx, ly): nbrs.append([nx, ly, false])
			if standable(x + dx, y - 1): nbrs.append([x + dx, y - 1, false])
		if not sol(x, y + 1) and occ(x, y + 1):
			var ly2: int = y
			while not sol(x, ly2 + 1) and occ(x, ly2 + 1): ly2 += 1
			nbrs.append([x, ly2, false])
		if grounded:
			for k in range(1, JH + 1):
				if occ(x, y - k): nbrs.append([x, y - k, false])
				else: break
		elif not dj:
			for k in range(1, JH + 1):
				if occ(x, y - k): nbrs.append([x, y - k, true])
				else: break
		for nb in nbrs:
			var key: int = idx(nb[0], nb[1]) * 2 + (1 if nb[2] else 0)
			if not seen.has(key):
				seen[key] = true
				reach[idx(nb[0], nb[1])] = 1
				q.append(nb)

	var f := FileAccess.open("res://tools/_reach_%s.raw" % tag, FileAccess.WRITE)
	f.store_buffer(reach)
	f.close()
	var cnt := 0
	for b in reach: if b == 1: cnt += 1
	print("BFS from atlas=%d tag=%s start=(%d,%d) reached=%d states=%d" % [from_atlas, tag, sx, sy, cnt, seen.size()])
	quit()
