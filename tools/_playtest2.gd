extends SceneTree
## Physics-aware playtest of Level29 w/ DOUBLE JUMP modeled (per memory/vania-level29-realdoors.md):
## state = (x,y,morph,dj_used). Walk/fall/step-up as before; jump 1..JH from a grounded stand;
## if airborne with dj_used=false, ONE more 1..JH climb allowed (consumes dj_used).
## Run: Godot --headless --path . -s tools/_playtest2.gd

const W := 580
const H := 450
const JH := 4
var MORPH_CELL := Vector2i(-9, -9)
var solid := PackedByteArray()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int, m: bool) -> bool:
	return not sol(x, y) and (m or not sol(x, y - 1))
func standable(x: int, y: int, m: bool) -> bool:
	return occ(x, y, m) and sol(x, y + 1)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and (terr.get_cell_atlas_coords(c).x < 45 or terr.get_cell_atlas_coords(c).x >= 67):
			solid[idx(c.x, c.y)] = 1
	var mk = scn.get_node("Markers")
	var goal: Vector2i = Vector2i(-9,-9)
	var start_tile := Vector2i(-9, -9)
	for c in mk.get_used_cells():
		var a = mk.get_cell_atlas_coords(c).x
		if a == 19: goal = c
		if a == 18: start_tile = c
	var pwc = scn.get_node("Powerups").get_used_cells()
	if pwc.size() > 0: MORPH_CELL = pwc[0]
	var sx:int = start_tile.x; var sy:int = start_tile.y
	while sy < H - 2 and not standable(sx, sy, false): sy += 1

	# state key: ((y*W+x)*2 + (morph?1:0)) * 2 + (dj_used?1:0)
	var seen := {}
	var q := [[sx, sy, false, false]]
	seen[0] = true
	var start_key: int = (idx(sx,sy)*2 + 0)*2 + 0
	seen.clear(); seen[start_key] = true
	var reached_goal := false
	var maxy := sy
	var got_morph := false
	while not q.is_empty():
		var s = q.pop_back()
		var x: int = s[0]; var y: int = s[1]; var m: bool = s[2]; var dj: bool = s[3]
		if x == MORPH_CELL.x and y == MORPH_CELL.y: m = true; got_morph = true
		if Vector2i(x, y) == goal: reached_goal = true
		maxy = max(maxy, y)
		var grounded: bool = standable(x, y, m)
		var nbrs := []  # [x,y,morph,dj_used]
		for dx in [-1, 1]:
			var nx: int = x + dx
			if occ(nx, y, m):
				var ly: int = y
				while not sol(nx, ly + 1) and occ(nx, ly + 1, m): ly += 1
				if occ(nx, ly, m): nbrs.append([nx, ly, m, false])  # landing on ground resets dj
			if standable(x + dx, y - 1, m): nbrs.append([x + dx, y - 1, m, false])
		if not sol(x, y + 1) and occ(x, y + 1, m):
			var ly2: int = y
			while not sol(x, ly2 + 1) and occ(x, ly2 + 1, m): ly2 += 1
			nbrs.append([x, ly2, m, false])
		if grounded:
			for k in range(1, JH + 1):
				if occ(x, y - k, m): nbrs.append([x, y - k, m, false])  # dj still available at jump apex
				else: break
		elif not dj:
			# airborne (mid-arc cell reached via a jump), double-jump: one more 1..JH climb, consumes dj
			for k in range(1, JH + 1):
				if occ(x, y - k, m): nbrs.append([x, y - k, m, true])
				else: break
		for nb in nbrs:
			var nm: bool = nb[2] or (nb[0] == MORPH_CELL.x and nb[1] == MORPH_CELL.y)
			var ndj: bool = nb[3]
			var key: int = (idx(nb[0], nb[1]) * 2 + (1 if nm else 0)) * 2 + (1 if ndj else 0)
			if not seen.has(key):
				seen[key] = true
				q.append([nb[0], nb[1], nm, ndj])

	print("PLAYTEST2(dj) start=(%d,%d) goal=%s morph_reachable=%s GOAL_REACHABLE=%s deepest_y=%d/%d states=%d" % [
		sx, sy, str(goal), str(got_morph), str(reached_goal), maxy, goal.y, seen.size()])
	quit()
