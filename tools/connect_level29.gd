extends SceneTree
## Loads Level29.tscn (preserving all edits) and PUNCHES OPEN the thin (1-tile) walls that block
## progress, spreading reachable open space outward from the player start until the map connects.
## Only carves a wall cell when one side is reachable-open and the other side is open-but-unreachable
## (so solid masses aren't swiss-cheesed). Saves back to Level29.tscn.
## Run: Godot --headless --path . -s tools/connect_level29.gd

const W := 480
const H := 450
const MAX_ROUNDS := 30
const CARVE_CAP := 40000
const WALL_MAX := 3     # punch through walls up to this many tiles thick (Metroid doorways are ~2-3)

func idx(x: int, y: int) -> int: return y * W + x
const DIRS := [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]
const DIRS_PUNCH := [Vector2i(1,0), Vector2i(-1,0)]   # HORIZONTAL punches only — never hole a floor/ceiling
# a cell is on a room SEAM if it's within 1 tile of a screen boundary (screens are 16x15 tiles).
# Metroid's room connections live at these seams, so only punching here keeps room interiors intact.
func on_seam(x: int, y: int) -> bool:
	var mx: int = x % 16; var my: int = y % 15
	return mx <= 1 or mx >= 15 or my <= 1 or my >= 14

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	# solid grid
	var solid := PackedByteArray(); solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H:
			var ax: int = terr.get_cell_atlas_coords(c).x
			if ax < 45:            # 45+ = water/hook/deco = non-solid
				solid[idx(c.x, c.y)] = 1
	# start open cell (from PlayerStart)
	var ps = scn.get_node("Spawns/PlayerStart")
	var sx := int(ps.position.x / 16.0)
	var sy := int(ps.position.y / 16.0) - 1
	if sy < 0: sy = 0
	# nudge to an open cell if needed
	if solid[idx(sx, sy)] == 1:
		for dy in range(0, 6):
			if solid[idx(sx, max(0, sy - dy))] == 0: sy = max(0, sy - dy); break

	var open_total := 0
	for i in solid.size():
		if solid[i] == 0: open_total += 1

	var total_carved := 0
	var reach := PackedByteArray()
	for round in MAX_ROUNDS:
		# BFS reachable open cells from start (4-neighbour)
		reach = PackedByteArray(); reach.resize(W * H)
		var q := PackedInt32Array([idx(sx, sy)]); reach[idx(sx, sy)] = 1
		var head := 0
		while head < q.size():
			var c: int = q[head]; head += 1
			var cx: int = c % W; var cy: int = c / W
			for d in DIRS:
				var nx: int = cx + d.x; var ny: int = cy + d.y
				if nx < 0 or nx >= W or ny < 0 or ny >= H: continue
				var ni: int = idx(nx, ny)
				if solid[ni] == 0 and reach[ni] == 0:
					reach[ni] = 1; q.append(ni)
		# from each reachable-open cell, tunnel through walls up to WALL_MAX thick to reach
		# open space on the far side that isn't reachable yet (this opens sealed doorways).
		var cset := {}
		for y in range(1, H - 1):
			for x in range(1, W - 1):
				var here: int = idx(x, y)
				if solid[here] == 1 or reach[here] == 0: continue
				for d in DIRS_PUNCH:
					var open_step := -1
					for s in range(1, WALL_MAX + 2):
						var nx: int = x + d.x * s; var ny: int = y + d.y * s
						if nx < 0 or nx >= W or ny < 0 or ny >= H: break
						if solid[idx(nx, ny)] == 0: open_step = s; break
					if open_step >= 2:   # at least 1 solid before the open cell = a wall to punch
						var tgt: int = idx(x + d.x * open_step, y + d.y * open_step)
						if reach[tgt] == 0:
							# only punch walls that lie on a screen seam (a room boundary)
							var all_seam := true
							for s in range(1, open_step):
								if not on_seam(x + d.x * s, y + d.y * s): all_seam = false; break
							if all_seam:
								for s in range(1, open_step):
									cset[idx(x + d.x * s, y + d.y * s)] = true
		var carves := PackedInt32Array()
		for k in cset.keys(): carves.append(k)
		if carves.size() == 0: break
		for ci in carves:
			var i: int = ci
			solid[i] = 0
			terr.erase_cell(Vector2i(i % W, i / W))
		total_carved += carves.size()
		if total_carved > CARVE_CAP: break

	# final coverage
	var reachable := 0
	for i in reach.size():
		if reach[i] == 1: reachable += 1

	for n in scn.get_children():
		n.owner = scn
	# re-set owners recursively so pack keeps the tree
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("carved=%d  open_total=%d  reachable=%d (%.0f%%)  err=%d" % [
		total_carved, open_total, reachable, 100.0 * reachable / max(1, open_total), err])
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
