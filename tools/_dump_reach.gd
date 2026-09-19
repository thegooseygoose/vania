extends SceneTree
## Like _dump_area.gd but overlays fwd/bwd reachability (from the saved .raw files) on top of
## solid/open terrain: 'X'=reached both ways, 'F'=fwd-only (the real frontier to bridge),
## 'B'=bwd-only, '.'=open but unreached by either, '#'=solid.
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
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	var bwd := fb.get_buffer(W*H); fb.close()
	print("dumping x=%d..%d y=%d..%d (#=solid X=both F=fwd-only B=bwd-only .=open/unreached)" % [x0,x1,y0,y1])
	for y in range(y0, y1+1):
		var line := "y=%3d: " % y
		for x in range(x0, x1+1):
			var i := idx(x,y)
			if solid[i]==1: line += "#"
			elif fwd[i]==1 and bwd[i]==1: line += "X"
			elif fwd[i]==1: line += "F"
			elif bwd[i]==1: line += "B"
			else: line += "."
		print(line)
	quit()
