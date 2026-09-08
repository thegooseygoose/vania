extends SceneTree
## Locks Level29 to the USER'S start marker (Markers atlas 18): removes any other starter (aligns the
## PlayerStart node to it), puts the Morph Ball on it, and PHYSICS-places the GOAL (atlas 19) at the
## farthest cell reachable FROM that start (walk/fall/jump/morph), keeping the start marker. Saves.
## Run: Godot --headless --path . -s tools/place_goal.gd

const W := 480
const H := 450
const JH := 4
var solid := PackedByteArray()
var MORPH := Vector2i(-9, -9)

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int, m: bool) -> bool: return not sol(x, y) and (m or not sol(x, y - 1))
func standable(x: int, y: int, m: bool) -> bool: return occ(x, y, m) and sol(x, y + 1)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and terr.get_cell_atlas_coords(c).x < 45:
			solid[idx(c.x, c.y)] = 1
	var mk = scn.get_node("Markers")
	# THE start = the user's atlas-18 tile (keep it); remove goals + any extra start tiles
	var start_tile := Vector2i(-9, -9)
	var to_erase := []
	for c in mk.get_used_cells():
		var ax := mk.get_cell_atlas_coords(c).x
		if ax == 18 and start_tile.x < 0:
			start_tile = c            # the FIRST start tile is THE start
		else:
			to_erase.append(c)        # goals + any other start tiles get removed
	for c in to_erase: mk.erase_cell(c)
	if start_tile.x < 0:
		print("NO START TILE (atlas 18) found — aborting"); quit(); return

	var sx := start_tile.x; var sy := start_tile.y
	while sy < H - 2 and not standable(sx, sy, true): sy += 1

	# align the PlayerStart node to the start tile (no conflicting starter)
	var ps = scn.get_node("Spawns/PlayerStart")
	ps.position = Vector2(sx * 16 + 8, (sy + 1) * 16)
	# Morph Ball on the start so the world is traversable
	var pw = scn.get_node("Powerups")
	for cc in pw.get_used_cells(): pw.erase_cell(cc)
	pw.set_cell(Vector2i(sx, sy), 0, Vector2i(48, 0))
	MORPH = Vector2i(sx, sy)

	# physics BFS from start (with morph) -> farthest reachable standable cell = GOAL
	var seen := {}
	var q := [[sx, sy, true]]; seen[idx(sx, sy) * 2 + 1] = true
	var far := Vector2i(sx, sy); var fard := 0; var reach_stand := 0
	while not q.is_empty():
		var s = q.pop_back()
		var x: int = s[0]; var y: int = s[1]; var m: bool = s[2]
		if standable(x, y, m):
			reach_stand += 1
			var dd: int = abs(x - sx) + abs(y - sy)
			if dd > fard: fard = dd; far = Vector2i(x, y)
		var nbrs := []
		for dx in [-1, 1]:
			var nx: int = x + dx
			if occ(nx, y, m):
				var ly: int = y
				while not sol(nx, ly + 1) and occ(nx, ly + 1, m): ly += 1
				if occ(nx, ly, m): nbrs.append([nx, ly, m])
			if standable(x + dx, y - 1, m): nbrs.append([x + dx, y - 1, m])
		if not sol(x, y + 1) and occ(x, y + 1, m):
			var ly2: int = y
			while not sol(x, ly2 + 1) and occ(x, ly2 + 1, m): ly2 += 1
			nbrs.append([x, ly2, m])
		if standable(x, y, m):
			for k in range(1, JH + 1):
				if occ(x, y - k, m): nbrs.append([x, y - k, m])
				else: break
		for nb in nbrs:
			var key: int = idx(nb[0], nb[1]) * 2 + (1 if nb[2] else 0)
			if not seen.has(key): seen[key] = true; q.append(nb)

	mk.set_cell(far, 0, Vector2i(19, 0))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("START(user)=%s reachable=%d GOAL=%s dist=%d err=%d" % [str(Vector2i(sx, sy)), reach_stand, str(far), fard, err])
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
