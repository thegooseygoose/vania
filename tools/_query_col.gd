extends SceneTree
const W := 580
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var xs := []
	for a in args: xs.append(int(a))
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and terr.get_cell_atlas_coords(c).x<45: solid[idx(c.x,c.y)]=1
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	var bwd := fb.get_buffer(W*H); fb.close()
	for x in xs:
		var top_bwd=-1; var bot_bwd=-1
		for y in range(H):
			if bwd[idx(x,y)]==1:
				if top_bwd<0: top_bwd=y
				bot_bwd=y
		var top_fwd=-1; var bot_fwd=-1
		for y in range(H):
			if fwd[idx(x,y)]==1:
				if top_fwd<0: top_fwd=y
				bot_fwd=y
		print("x=%d  fwd_y=[%d..%d]  bwd_y=[%d..%d]" % [x, top_fwd, bot_fwd, top_bwd, bot_bwd])
	quit()
