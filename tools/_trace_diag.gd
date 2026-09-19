extends SceneTree
## For each x along the known zigzag leg1 diagonal (x_start=172,dir=-1 from y=349), compute the
## expected step position and report whether fwd/bwd actually reached exactly that cell (and the
## cells immediately above it, since "standing on the step" means the OPEN cell above the solid one).
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	var bwd := fb.get_buffer(W*H); fb.close()
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	print("x  step_y(solid?)  stand_y(open,fwd,bwd)")
	for x in range(172, 17, -5):
		var step_y: int = 349 - (172 - x)
		var stand_y: int = step_y - 1
		var solid: bool = terr.get_cell_source_id(Vector2i(x, step_y)) >= 0
		var open_: bool = terr.get_cell_source_id(Vector2i(x, stand_y)) < 0
		var f: bool = fwd[idx(x, stand_y)] == 1
		var b: bool = bwd[idx(x, stand_y)] == 1
		print("x=%d step_y=%d solid=%s stand_y=%d open=%s fwd=%s bwd=%s" % [x, step_y, str(solid), stand_y, str(open_), str(f), str(b)])
	quit()
