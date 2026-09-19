extends SceneTree
## Better gap-finder: connected components of (open & fwd==1 & bwd==0) cells that are adjacent
## (4-neighbour) to at least one bwd==1 cell somewhere in the component. Reports the TALLEST such
## components (max_y - min_y) since those are the "cavernous vertical gap needs a staircase" cases.
const W := 580
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (terr.get_cell_atlas_coords(c).x<45 or terr.get_cell_atlas_coords(c).x>=67): solid[idx(c.x,c.y)]=1
	var ff := FileAccess.open("res://tools/_reach_fwd.raw", FileAccess.READ)
	var fwd := ff.get_buffer(W*H); ff.close()
	var fb := FileAccess.open("res://tools/_reach_bwd.raw", FileAccess.READ)
	var bwd := fb.get_buffer(W*H); fb.close()

	var is_gap := func(x,y): return solid[idx(x,y)]==0 and fwd[idx(x,y)]==1 and bwd[idx(x,y)]==0
	var visited := PackedByteArray(); visited.resize(W*H)
	var comps := []  # [minx,miny,maxx,maxy,size,touches_bwd]
	for x in range(W):
		for y in range(H):
			if visited[idx(x,y)]==1: continue
			if not is_gap.call(x,y): visited[idx(x,y)]=1; continue
			# flood this gap component
			var q := [idx(x,y)]; visited[idx(x,y)]=1
			var minx=x; var maxx=x; var miny=y; var maxy=y; var sz=0; var touches=false
			var h=0
			while h < q.size():
				var c = q[h]; h+=1; sz+=1
				var cx=c%W; var cy=c/W
				minx=min(minx,cx); maxx=max(maxx,cx); miny=min(miny,cy); maxy=max(maxy,cy)
				for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
					var nx=cx+d.x; var ny=cy+d.y
					if nx<0 or nx>=W or ny<0 or ny>=H: continue
					if bwd[idx(nx,ny)]==1: touches=true
					if visited[idx(nx,ny)]==1: continue
					if is_gap.call(nx,ny):
						visited[idx(nx,ny)]=1
						q.append(idx(nx,ny))
					else:
						visited[idx(nx,ny)]=1 if false else visited[idx(nx,ny)]  # no-op, keep unvisited for its own pass
			comps.append([minx,miny,maxx,maxy,sz,touches])
	var total_gap := 0
	for b in fwd.size(): pass
	for i in range(W*H): if fwd[i]==1 and bwd[i]==0 and solid[i]==0: total_gap += 1
	print("total gap cells (fwd&!bwd&open)=%d  total_components=%d  touching_components=%d" % [
		total_gap, comps.size(), comps.filter(func(c): return c[5]).size()])
	var all_comps = comps.duplicate()
	all_comps.sort_custom(func(a,b): return (a[3]-a[1]) > (b[3]-b[1]))
	print("ALL 33 gap components (tallest first), bbox + touches flag:")
	for c in all_comps:
		print("  h=%d w=%d bbox=(%d,%d)-(%d,%d) size=%d touches=%s" % [c[3]-c[1], c[2]-c[0], c[0],c[1],c[2],c[3], c[4], str(c[5])])
	quit()
