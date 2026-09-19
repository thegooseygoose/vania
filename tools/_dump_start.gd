extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var mk = scn.get_node("Markers")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and terr.get_cell_atlas_coords(c).x<45: solid[idx(c.x,c.y)]=1
	print("Markers cells:")
	for c in mk.get_used_cells(): print("  (%d,%d) atlas=%d"%[c.x,c.y,mk.get_cell_atlas_coords(c).x])
	var start_tile := Vector2i(-9,-9)
	for c in mk.get_used_cells():
		if mk.get_cell_atlas_coords(c).x==18: start_tile=c; break
	print("start_tile=", start_tile)
	var sx:int = start_tile.x; var sy:int = start_tile.y
	print("local grid around start (rows sy-8..sy+8, cols sx-15..sx+15), # = solid . = open")
	for y in range(sy-8, sy+9):
		var line := "y=%3d: " % y
		for x in range(sx-15, sx+16):
			if x<0 or x>=W or y<0 or y>=H: line += "?"
			else: line += ("#" if solid[idx(x,y)]==1 else ".")
		print(line)
	quit()
