extends SceneTree
## Prints every x in [x0,x1] where (x,y) is OPEN (occ=true), for a single row y -- ground truth,
## no ASCII parsing. Run: -- y x0 x1
const W := 580
const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func sol(x:int,y:int)->bool:
	if x<0 or x>=W or y<0 or y>=H: return true
	return solid[idx(x,y)]==1
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var y:int=int(args[0]); var x0:int=int(args[1]); var x1:int=int(args[2])
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var open_xs := []
	for x in range(x0,x1+1):
		if not sol(x,y): open_xs.append(x)
	print("row y=%d open columns in [%d,%d]: %s" % [y, x0, x1, str(open_xs)])
	quit()
