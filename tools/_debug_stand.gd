extends SceneTree
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
	var x:int = int(args[0])
	var y0:int = int(args[1]); var y1:int = int(args[2])
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	for y in range(y0,y1+1):
		print("x=%d y=%d occ=%s sol_below=%s standable=%s" % [x,y,occ(x,y),sol(x,y+1),standable(x,y)])
	quit()
