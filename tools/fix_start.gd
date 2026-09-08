extends SceneTree
## Repositions the PlayerStart (and Morph Ball) into the LARGEST open region of Level29 so the player
## isn't boxed inside solid blocks. Saves back to Level29.tscn.
## Run: Godot --headless --path . -s tools/fix_start.gd

const W := 480
const H := 450
func idx(x: int, y: int) -> int: return y * W + x

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid := PackedByteArray(); solid.resize(W * H)
	for c in terr.get_used_cells():
		if c.x >= 0 and c.x < W and c.y >= 0 and c.y < H and terr.get_cell_atlas_coords(c).x < 45:
			solid[idx(c.x, c.y)] = 1

	# label open components, track the largest
	var comp := PackedInt32Array(); comp.resize(W * H)
	for i in comp.size(): comp[i] = -1
	var best_cells := PackedInt32Array()
	var best_size := 0
	var cid := 0
	for sy0 in range(0, H):
		for sx0 in range(0, W):
			var s0 := idx(sx0, sy0)
			if solid[s0] == 1 or comp[s0] != -1: continue
			# BFS this component
			var cells := PackedInt32Array()
			var q := PackedInt32Array([s0]); comp[s0] = cid
			var head := 0
			while head < q.size():
				var c := q[head]; head += 1
				cells.append(c)
				var cx := c % W; var cy := c / W
				for d in [Vector2i(1,0), Vector2i(-1,0), Vector2i(0,1), Vector2i(0,-1)]:
					var nx := cx + d.x; var ny := cy + d.y
					if nx < 0 or nx >= W or ny < 0 or ny >= H: continue
					var ni := idx(nx, ny)
					if solid[ni] == 0 and comp[ni] == -1:
						comp[ni] = cid; q.append(ni)
			if cells.size() > best_size:
				best_size = cells.size(); best_cells = cells
			cid += 1

	# find a standable cell in the largest region (open, open above, solid floor below)
	var startc := Vector2i(-1, -1)
	for c in best_cells:
		var x := c % W; var y := c / W
		if y + 1 < H and solid[idx(x, y + 1)] == 1 and y - 1 >= 0 and solid[idx(x, y - 1)] == 0:
			startc = Vector2i(x, y); break
	if startc.x < 0 and best_cells.size() > 0:
		var c0 := best_cells[0]; startc = Vector2i(c0 % W, c0 / W)

	var ps = scn.get_node("Spawns/PlayerStart")
	ps.position = Vector2(startc.x * 16 + 8, (startc.y + 1) * 16)

	# move the Morph Ball into this region, a few tiles from the start on a floor
	var pw = scn.get_node("Powerups")
	for cc in pw.get_used_cells(): pw.erase_cell(cc)
	var mb := startc
	for dx in [2, 3, -2, 4, -3, 5]:
		var x := startc.x + dx
		if x < 1 or x >= W - 1: continue
		if solid[idx(x, startc.y)] == 0 and solid[idx(x, startc.y + 1)] == 1:
			mb = Vector2i(x, startc.y); break
	pw.set_cell(mb, 0, Vector2i(48, 0))

	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("largest open region=%d cells, start=%s morph=%s err=%d" % [best_size, str(startc), str(mb), err])
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
