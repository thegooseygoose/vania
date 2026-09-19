extends SceneTree
## Diffs _reach_fwd.raw vs _reach_bwd.raw (from _bfs_general.gd) to find where backward reachability
## falls short of forward. Reports, per column, tall vertical runs of "fwd-reachable, not
## bwd-reachable" solid-adjacent OPEN cells that touch (are adjacent to) the existing bwd frontier —
## i.e. real climbable gaps, not disconnected islands. Also prints solid map context for the best
## candidate so a staircase can be planned.
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

	# For each column, find runs of (open & fwd==1 & bwd==0) cells that are vertically adjacent
	# (above or below) to a bwd==1 cell in the SAME column (touches the frontier -> reachable by
	# walking there, just not currently laddered).
	var candidates := []  # [x, run_top_y, run_bot_y, height, touches_bwd_at_y]
	for x in range(0, W):
		var y := 0
		while y < H:
			if solid[idx(x,y)]==0 and fwd[idx(x,y)]==1 and bwd[idx(x,y)]==0:
				var top := y
				while y < H and solid[idx(x,y)]==0 and fwd[idx(x,y)]==1 and bwd[idx(x,y)]==0: y += 1
				var bot := y - 1
				var h := bot - top + 1
				if h >= 10:
					# does this run touch a bwd-reached cell just above top or just below bot?
					var touch_above := top > 0 and bwd[idx(x, top-1)] == 1
					var touch_below := bot < H-1 and bwd[idx(x, bot+1)] == 1
					if touch_above or touch_below:
						candidates.append([x, top, bot, h, touch_above, touch_below])
			else:
				y += 1

	candidates.sort_custom(func(a,b): return a[3] > b[3])
	print("top 20 candidate gap-runs (x, top_y, bot_y, height, touch_above, touch_below):")
	for i in range(min(20, candidates.size())):
		print("  ", candidates[i])
	quit()
