extends SceneTree
## Scans a rect and prints every cell where standable(x,y) is true -- ground truth, no ASCII
## hand-counting. Run: -- x0 x1 y0 y1
const W := 580
const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func sol(x:int,y:int)->bool:
	if x<0 or x>=W or y<0 or y>=H: return true
	return solid[idx(x,y)]==1
func occ(x:int,y:int)->bool: return not sol(x,y)
func standable(x:int,y:int)->bool: return occ(x,y) and sol(x,y+1)
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var x0:int=int(args[0]); var x1:int=int(args[1]); var y0:int=int(args[2]); var y1:int=int(args[3])
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	var bwd := fb.get_buffer(W*H); fb.close()
	for y in range(y0,y1+1):
		for x in range(x0,x1+1):
			if standable(x,y):
				var i := idx(x,y)
				var tag := "F" if fwd[i]==1 and bwd[i]==0 else ("B" if bwd[i]==1 and fwd[i]==0 else ("X" if fwd[i]==1 and bwd[i]==1 else "."))
				print("STANDABLE x=%d y=%d reach=%s" % [x,y,tag])
	quit()
