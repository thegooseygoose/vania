extends SceneTree
const W := 480; const H := 450
const GROUND_TYPES := [25, 31]   # serp, virus (alternate)
const TURRET := 35
const BUG := 29
var solid := PackedByteArray()
var fwd := PackedByteArray()
var occupied := {}
func idx(x:int,y:int)->int: return y*W+x
func sol(x:int,y:int)->bool:
	if x<0 or x>=W or y<0 or y>=H: return true
	return solid[idx(x,y)]==1
func near_occupied(x:int, y:int, r:int) -> bool:
	for dx in range(-r, r+1):
		for dy in range(-r, r+1):
			if occupied.has(Vector2i(x+dx, y+dy)): return true
	return false
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var mk = scn.get_node("Markers")
	var pw = scn.get_node("Powerups")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	fwd = ff.get_buffer(W*H); ff.close()

	for c in et.get_used_cells(): occupied[c] = true
	for c in mk.get_used_cells(): occupied[c] = true
	for c in pw.get_used_cells(): occupied[c] = true

	var placed := 0
	var type_i := 0
	var rng = RandomNumberGenerator.new()
	rng.seed = 12345
	var GRID := 13
	for gx in range(0, W, GRID):
		for gy in range(0, H, GRID):
			if placed >= 90: break
			var found := false
			for dx in range(-5, 6):
				for dy in range(-5, 6):
					var x: int = gx+dx; var y: int = gy+dy
					if x<1 or x>=W-1 or y<1 or y>=H-2: continue
					if fwd[idx(x,y)] != 1: continue
					if sol(x,y) or sol(x,y-1): continue
					if not sol(x,y+1): continue
					if near_occupied(x, y, 3): continue
					var kind: int = GROUND_TYPES[type_i % GROUND_TYPES.size()]
					if rng.randf() < 0.12 and sol(x, y-3):
						et.set_cell(Vector2i(x, y-2), 0, Vector2i(TURRET, 0))
					elif rng.randf() < 0.15:
						et.set_cell(Vector2i(x, y-2), 0, Vector2i(BUG, 0))
					else:
						et.set_cell(Vector2i(x, y), 0, Vector2i(kind, 0))
					occupied[Vector2i(x,y)] = true
					type_i += 1
					placed += 1
					found = true
					break
				if found: break
		if placed >= 90: break
	print("placed %d new enemies" % placed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
