extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	# find every "wall ledge" row (solid run starting at x=160, width>=4) between y40 and y195,
	# then check if there's a "mid ledge" (solid run around x166-170) exactly 4-6 rows above it
	for y in range(195, 39, -1):
		if solid[idx(160,y)]==1 and solid[idx(161,y)]==1 and solid[idx(162,y)]==1 and solid[idx(163,y)]==1 and solid[idx(164,y)]==0:
			# it's a wall-ledge row (160-163 solid, 164 open... adjust) -- just check 160-164 pattern loosely
			pass
	# simpler: just print the solid pattern's leftmost run width at x160 per row, for eyeballing
	for y in range(40, 196):
		var run := 0
		var x := 160
		while x < 166 and solid[idx(x,y)]==1:
			run += 1; x += 1
		if run >= 4:
			print("wall-ledge row y=%d (run=%d)" % [y, run])
	quit()
