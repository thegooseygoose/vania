extends SceneTree
## Keeps Level29's faithful map layout, makes it BEATABLE by connecting rooms with MINIMAL clean
## doorway cuts (best thin-wall punch per room pair, prefer floor-level horizontal). Starts the
## player in a roomy open spot; places a GOAL at the deepest reachable spot. Saves Level29.tscn.
## Run: Godot --headless --path . -s tools/connect_rooms.gd

const W := 480
const H := 450
const MIN_ROOM := 20
const DMAX := 4

var solid := PackedByteArray()
var comp := PackedInt32Array()
var parent := PackedInt32Array()

func idx(x: int, y: int) -> int: return y * W + x
func sol(x: int, y: int) -> bool:
	if x < 0 or x >= W or y < 0 or y >= H: return true
	return solid[idx(x, y)] == 1
func opn(x: int, y: int) -> bool: return not sol(x, y)
func find(a: int) -> int:
	while parent[a] != a:
		parent[a] = parent[parent[a]]; a = parent[a]
	return a

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and terr.get_cell_atlas_coords(c).x < 45:
			solid[idx(c.x, c.y)] = 1
	comp.resize(W * H)
	for i in comp.size(): comp[i] = -1
	var sizes := {}
	var cid := 0
	for y0 in range(H):
		for x0 in range(W):
			var s0 := idx(x0, y0)
			if solid[s0] == 1 or comp[s0] != -1: continue
			var q := PackedInt32Array([s0]); comp[s0] = cid; var head := 0; var sz := 0
			while head < q.size():
				var c := q[head]; head += 1; sz += 1
				var cx := c % W; var cy := c / W
				for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var nx: int = cx + d.x; var ny: int = cy + d.y
					if nx >= 0 and nx < W and ny >= 0 and ny < H and solid[idx(nx, ny)] == 0 and comp[idx(nx, ny)] == -1:
						comp[idx(nx, ny)] = cid; q.append(ny * W + nx)
			sizes[cid] = sz; cid += 1
	parent.resize(cid)
	for i in cid: parent[i] = i

	# best thin-wall cut per unordered room pair
	var best := {}   # key "a_b" -> candidate array
	for y in range(1, H - 1):
		for x in range(1, W - 1):
			if not sol(x, y): continue
			# horizontal
			var la := 0
			for s in range(1, DMAX + 1):
				if opn(x - s, y): la = s; break
			var ra := 0
			for s in range(1, DMAX + 1):
				if opn(x + s, y): ra = s; break
			if la > 0 and ra > 0 and (la + ra - 1) <= 3:   # door is 3 wide -> only span walls <=3 thick
				var cl: int = comp[idx(x - la, y)]; var cr: int = comp[idx(x + ra, y)]
				if cl != cr and int(sizes.get(cl, 0)) >= MIN_ROOM and int(sizes.get(cr, 0)) >= MIN_ROOM:
					if (sol(x - la, y + 1) or sol(x - la, y + 2)) and (sol(x + ra, y + 1) or sol(x + ra, y + 2)):
						var cost := float(la + ra - 1) + float(H - y) * 0.001
						_offer(best, cl, cr, [cost, x - la + 1, x + ra - 1, y, cl, cr, true])
			# vertical
			var ua := 0
			for s in range(1, DMAX + 1):
				if opn(x, y - s): ua = s; break
			var da := 0
			for s in range(1, DMAX + 1):
				if opn(x, y + s): da = s; break
			if ua > 0 and da > 0:
				var cu: int = comp[idx(x, y - ua)]; var cd: int = comp[idx(x, y + da)]
				if cu != cd and int(sizes.get(cu, 0)) >= MIN_ROOM and int(sizes.get(cd, 0)) >= MIN_ROOM:
					var cost2 := float(ua + da - 1) + 0.5
					_offer(best, cu, cd, [cost2, x, y - ua + 1, y + da - 1, cu, cd, false])
	var cands := best.values()
	cands.sort_custom(func(a, b): return a[0] < b[0])

	var carved := 0
	var doors := 0
	var et = scn.get_node("EnemyTiles")
	for cnd in cands:
		var a: int = cnd[4]; var b: int = cnd[5]
		if find(a) == find(b): continue
		if cnd[6]:   # HORIZONTAL: a clean 3-wide x 3-tall doorway with a real DOOR (L,M,R) + floor
			var y: int = cnd[3]
			var cxc: int = int((cnd[1] + cnd[2]) / 2.0)
			for cx in range(cxc - 1, cxc + 2):
				for cy in range(y - 2, y + 1):
					solid[idx(cx, cy)] = 0; terr.erase_cell(Vector2i(cx, cy))   # open the doorway
				solid[idx(cx, y + 1)] = 1; terr.set_cell(Vector2i(cx, y + 1), 0, Vector2i(13, 0))  # solid floor
			# 3-in-a-row door: LEFT(26), MID(27), RIGHT(28)
			et.set_cell(Vector2i(cxc - 1, y), 0, Vector2i(26, 0))
			et.set_cell(Vector2i(cxc, y), 0, Vector2i(27, 0))
			et.set_cell(Vector2i(cxc + 1, y), 0, Vector2i(28, 0))
			doors += 1
		else:        # VERTICAL: a 2-wide drop shaft (no door — Metroid vertical rooms are open shafts)
			for cy in range(cnd[2], cnd[3] + 1):
				solid[idx(cnd[1], cy)] = 0; terr.erase_cell(Vector2i(cnd[1], cy))
				if cnd[1] + 1 < W:
					solid[idx(cnd[1] + 1, cy)] = 0; terr.erase_cell(Vector2i(cnd[1] + 1, cy))
		parent[find(a)] = find(b); carved += 1

	# largest room + a roomy standable start (open above, floor below, open on a side)
	var bestc := -1; var bestsz := 0
	for k in sizes: if int(sizes[k]) > bestsz: bestsz = int(sizes[k]); bestc = k
	var startc := Vector2i(-1, -1)
	for y in range(2, H - 2):
		for x in range(2, W - 2):
			if comp[idx(x, y)] == bestc and sol(x, y + 1) and opn(x, y - 1) and opn(x, y - 2) and (opn(x - 1, y) or opn(x + 1, y)):
				startc = Vector2i(x, y); break
		if startc.x >= 0: break
	var ps = scn.get_node("Spawns/PlayerStart")
	ps.position = Vector2(startc.x * 16 + 8, (startc.y + 1) * 16)
	var pw = scn.get_node("Powerups")
	for cc in pw.get_used_cells(): pw.erase_cell(cc)
	pw.set_cell(startc, 0, Vector2i(48, 0))   # Morph Ball ON the start so you have it immediately

	# GOAL = deepest standable cell in the start's connected set
	var sroot := find(bestc)
	var goalc := startc
	for y in range(H - 2, 1, -1):
		var found := false
		for x in range(1, W - 1):
			var cc2: int = comp[idx(x, y)]
			if cc2 >= 0 and find(cc2) == sroot and sol(x, y + 1) and opn(x, y - 1):
				goalc = Vector2i(x, y); found = true; break
		if found: break
	var mk = scn.get_node("Markers")
	for cc in mk.get_used_cells(): mk.erase_cell(cc)
	mk.set_cell(goalc, 0, Vector2i(19, 0))

	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("connected cuts=%d start=%s goal=%s startroom=%d err=%d" % [carved, str(startc), str(goalc), bestsz, err])
	quit()

func _offer(best: Dictionary, a: int, b: int, cand: Array) -> void:
	var key := "%d_%d" % [min(a, b), max(a, b)]
	if not best.has(key) or cand[0] < best[key][0]:
		best[key] = cand

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
