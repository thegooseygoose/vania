extends SceneTree
const W := 480; const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func floor_row(x: int, y0: int) -> int:
	for y in range(y0, y0 + 12):
		if y < H and solid[idx(x, y)] == 1: return y
	return -1
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	print("door_floor (x=283,from y=299)=", floor_row(283,299))
	print("left_floor (x=280,from y=299)=", floor_row(280,299))
	print("right_floor (x=286,from y=299)=", floor_row(286,299))
	quit()
