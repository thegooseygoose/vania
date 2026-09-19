extends SceneTree
## A REALISTIC ability-gated beatability check for Level29 (not the earlier simplified BFS, which
## always assumed morph+double-jump were available from the start). Starts with ZERO abilities and
## does an iterative fixed-point BFS: explore with whatever's currently unlocked; whenever the
## explored set includes a new ability pickup, unlock it and re-run; repeat until GOAL is reached or
## no more progress is possible. Doors are NOT gated (shot is always available from spawn and any
## door is passable once you're near it — this matches the real game). Does NOT model grapple or
## wall-jump climbing (those are complex to approximate faithfully) — noted as a limitation.
const W := 480
const H := 450
const JH := 4
var solid := PackedByteArray()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func occ(x: int, y: int, morph: bool) -> bool:
	return not sol(x, y) and (morph or not sol(x, y - 1))
func standable(x: int, y: int, morph: bool) -> bool:
	return occ(x, y, morph) and sol(x, y + 1)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and (terr.get_cell_atlas_coords(c).x < 45 or terr.get_cell_atlas_coords(c).x >= 67):
			solid[idx(c.x, c.y)] = 1

	var mk = scn.get_node("Markers")
	var goal := Vector2i(-9, -9)
	var start_tile := Vector2i(-9, -9)
	for c in mk.get_used_cells():
		var a = mk.get_cell_atlas_coords(c).x
		if a == 19: goal = c
		if a == 18: start_tile = c
	var sx: int = start_tile.x; var sy: int = start_tile.y
	while sy < H - 2 and not standable(sx, sy, false): sy += 1

	# ability pickups: cell -> ability name
	var pw = scn.get_node("Powerups")
	const SHAPE_TO_ABILITY := {48: "morph", 49: "double_jump", 50: "break", 51: "grapple",
		52: "boomerang", 53: "walljump", 54: "waterwalk", 55: "dash", 56: "riderkick",
		57: "timeslow", 58: "hover", 66: "bombs", 65: "balljump"}
	var pickups := {}   # Vector2i -> ability name
	for c in pw.get_used_cells():
		var ax: int = pw.get_cell_atlas_coords(c).x
		if SHAPE_TO_ABILITY.has(ax):
			pickups[c] = SHAPE_TO_ABILITY[ax]

	var unlocked := {}   # ability name -> true
	var reached_goal := false
	var iterations := 0
	var seen := {}   # persists across iterations (only grows)
	while true:
		iterations += 1
		var morph: bool = unlocked.has("morph")
		var dj: bool = unlocked.has("double_jump")
		# re-seed the queue with EVERY previously-seen state (not just start) so already-explored
		# cells get a fresh chance to discover new neighbors under the just-updated movement rules
		# (e.g. a 1-tall gap deep inside known territory that only just became passable with morph).
		var q := []
		if seen.is_empty():
			q.append([sx, sy, false])
			seen[idx(sx, sy) * 2] = true
		else:
			for key in seen.keys():
				var cellidx: int = key / 2
				var cx: int = cellidx % W; var cy: int = cellidx / W
				var wasdj: bool = (key % 2) == 1
				q.append([cx, cy, wasdj])
		var new_pickup_found := ""
		while not q.is_empty():
			var s = q.pop_back()
			var x: int = s[0]; var y: int = s[1]; var usedj: bool = s[2]
			var cellv := Vector2i(x, y)
			if pickups.has(cellv) and not unlocked.has(pickups[cellv]):
				new_pickup_found = pickups[cellv]
			if cellv == goal: reached_goal = true
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
			elif dj and not usedj:
				for k in range(1, JH + 1):
					if occ(x, y - k, morph): nbrs.append([x, y - k, true])
					else: break
			for nb in nbrs:
				var key: int = idx(nb[0], nb[1]) * 2 + (1 if nb[2] else 0)
				if not seen.has(key):
					seen[key] = true
					q.append(nb)
		var minx := 99999; var maxx := -99999; var miny := 99999; var maxy := -99999
		for k in seen.keys():
			var cellidx: int = k / 2
			var cx: int = cellidx % W; var cy: int = cellidx / W
			minx = mini(minx, cx); maxx = maxi(maxx, cx); miny = mini(miny, cy); maxy = maxi(maxy, cy)
		print("  reached %d states this pass, bbox x=[%d..%d] y=[%d..%d]" % [seen.size(), minx, maxx, miny, maxy])
		if reached_goal:
			print("GOAL REACHED after unlocking: ", unlocked.keys(), " (iteration %d)" % iterations)
			break
		if new_pickup_found == "":
			print("STUCK — no new ability reachable. Currently unlocked: ", unlocked.keys())
			print("Pickups NOT yet reached: ")
			for c in pickups.keys():
				if not unlocked.has(pickups[c]):
					print("  ", pickups[c], " at ", c)
			break
		unlocked[new_pickup_found] = true
		print("iteration %d: unlocked '%s', re-exploring..." % [iterations, new_pickup_found])

	print("FINAL: reached_goal=%s unlocked=%s" % [str(reached_goal), str(unlocked.keys())])
	print("NOTE: this model does NOT simulate grapple-swinging or wall-jump climbing — if the real")
	print("solution needs either, this may under-report reachability (false 'stuck').")
	quit()
