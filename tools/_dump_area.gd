extends SceneTree
const W := 580
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var x0:int = int(args[0]); var x1:int = int(args[1])
	var y0:int = int(args[2]); var y1:int = int(args[3])
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	print("dumping x=%d..%d y=%d..%d (# solid, . open)" % [x0,x1,y0,y1])
	for y in range(y0, y1+1):
		var line := "y=%3d: " % y
		for x in range(x0, x1+1):
			line += ("#" if solid[idx(x,y)]==1 else ".")
		print(line)
	quit()
