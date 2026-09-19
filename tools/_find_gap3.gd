extends SceneTree
## Per memory's method: for each column x, find the TOPMOST bwd-reached row, then measure the
## open (non-solid) run extending upward from there. A tall run = bwd's climb capped by JH+double-
## jump height, not by rock -> exactly where a physical staircase is needed. Only reports columns
## where the top of that open run is ALSO fwd-reachable (a real, already-forward-reachable gap).
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and terr.get_cell_atlas_coords(c).x<45: solid[idx(c.x,c.y)]=1
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	var bwd := fb.get_buffer(W*H); fb.close()

	var results := []  # [x, top_bwd_y, run_top_y, run_height]
	for x in range(W):
		var top_bwd := -1
		for y in range(H):
			if bwd[idx(x,y)]==1: top_bwd = y; break
		if top_bwd < 0: continue
		# measure open run upward from top_bwd-1
		var y := top_bwd - 1
		var run_top := top_bwd
		while y >= 0 and solid[idx(x,y)]==0:
			run_top = y
			y -= 1
		var height := top_bwd - run_top
		var top_is_fwd = fwd[idx(x, run_top)] == 1
		results.append([x, top_bwd, run_top, height, top_is_fwd])

	results.sort_custom(func(a,b): return a[3] > b[3])
	print("columns_with_bwd=%d" % results.size())
	print("top 40 by height regardless of fwd flag:")
	for i in range(min(40, results.size())):
		var r = results[i]
		print("  x=%d  bwd_top_y=%d  run_top_y=%d  height=%d  top_is_fwd=%s" % [r[0], r[1], r[2], r[3], str(r[4])])
	quit()
