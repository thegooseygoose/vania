extends SceneTree
const W := 480; const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	# group doors into (L,M,R) triples
	var cellmap := {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: cellmap[c] = ax
	var doorL := []
	for c in cellmap.keys():
		if cellmap[c] == 26: doorL.append(c)
	print("total doors (L cells): ", doorL.size())
	var bad := []
	for L in doorL:
		# check headroom (2-tile clearance for standing) on BOTH sides approaching the door, at
		# the door's own row and one tile out on each side
		for dx in [-1, 0, 1, 2, 3, 4]:
			var x: int = L.x + dx
			var y: int = L.y
			var open_here: bool = solid[idx(x,y)]==0
			var open_above: bool = y>0 and solid[idx(x,y-1)]==0
			if open_here and not open_above:
				bad.append([L, Vector2i(x,y)])
				break
	print("doors with insufficient (<2-tile) headroom nearby: ", bad.size())
	for b in bad:
		print("  door@", b[0], " tight spot@", b[1])
	quit()
