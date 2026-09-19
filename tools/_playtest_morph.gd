extends SceneTree
## Physics-aware playtest of Level29: BFS over player states modelling walk, fall, jump (4 tiles),
## and morph (pass 1-tall gaps once the Morph Ball is collected). Reports whether the GOAL is
## actually reachable start->finish, and if not, how far you get (to pinpoint the break).
## Run: Godot --headless --path . -s tools/playtest.gd

const W := 480
const H := 450
const JH := 4                       # jump height in tiles
var MORPH_CELL := Vector2i(-9, -9)  # read from the Powerups layer at runtime
var solid := PackedByteArray()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int, m: bool) -> bool:      # player body can be here (2-tall, or 1-tall if morphed)
	return not sol(x, y) and (m or not sol(x, y - 1))
func standable(x: int, y: int, m: bool) -> bool:
	return occ(x, y, m) and sol(x, y + 1)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and terr.get_cell_atlas_coords(c).x < 45:
			solid[idx(c.x, c.y)] = 1
	var mk = scn.get_node("Markers")
	var goal: Vector2i = mk.get_used_cells()[0]
	var pwc = scn.get_node("Powerups").get_used_cells()
	if pwc.size() > 0: MORPH_CELL = pwc[0]
	# START = the user's painted START tile (Markers atlas 18) if present (it overrides PlayerStart
	# in-game), else the PlayerStart marker.
	var sx := 0; var sy := 0
	var start_tile := Vector2i(-9, -9)
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x == 18: start_tile = c; break
	if start_tile.x >= 0:
		sx = start_tile.x; sy = start_tile.y
	else:
		var ps = scn.get_node("Spawns/PlayerStart")
		sx = int(ps.position.x / 16.0); sy = int(ps.position.y / 16.0) - 1
	# ensure spawn is standable (drop it onto the floor if needed)
	while sy < H - 2 and not standable(sx, sy, false):
		sy += 1

	var seen := {}
	var start_key := idx(sx, sy) * 2
	var q := [[sx, sy, true]]
	seen[start_key] = true
	var reached_goal := false
	var maxy := sy
	var got_morph := false
	while not q.is_empty():
		var s = q.pop_back()
		var x: int = s[0]; var y: int = s[1]; var m: bool = s[2]
		if Vector2i(x, y) == MORPH_CELL or (m == false and abs(x - MORPH_CELL.x) <= 0 and y == MORPH_CELL.y):
			m = true
		# collect morph if standing on/at its cell (within the tile)
		if x == MORPH_CELL.x and y == MORPH_CELL.y: m = true; got_morph = true
		if Vector2i(x, y) == goal: reached_goal = true
		maxy = max(maxy, y)
		var nbrs := []
		# walk / walk-off-edge (auto-fall to landing)
		for dx in [-1, 1]:
			var nx: int = x + dx
			if occ(nx, y, m):
				var ly: int = y
				while not sol(nx, ly + 1) and occ(nx, ly + 1, m): ly += 1
				if occ(nx, ly, m): nbrs.append([nx, ly, m])
			# step up 1 (small lip)
			if standable(x + dx, y - 1, m): nbrs.append([x + dx, y - 1, m])
		# straight-down fall (shafts)
		if not sol(x, y + 1) and occ(x, y + 1, m):
			var ly2: int = y
			while not sol(x, ly2 + 1) and occ(x, ly2 + 1, m): ly2 += 1
			nbrs.append([x, ly2, m])
		# jump straight up (then walk/fall from the apex cells)
		if standable(x, y, m):
			for k in range(1, JH + 1):
				if occ(x, y - k, m): nbrs.append([x, y - k, m])
				else: break
		for nb in nbrs:
			var nm: bool = nb[2] or (nb[0] == MORPH_CELL.x and nb[1] == MORPH_CELL.y)
			var key: int = idx(nb[0], nb[1]) * 2 + (1 if nm else 0)
			if not seen.has(key):
				seen[key] = true
				q.append(nb)

	print("PLAYTEST start=(%d,%d) goal=%s morph_reachable=%s GOAL_REACHABLE=%s  deepest_y=%d/%d" % [
		sx, sy, str(goal), str(got_morph), str(reached_goal), maxy, goal.y])
	quit()
