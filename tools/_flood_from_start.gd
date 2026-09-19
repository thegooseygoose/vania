extends SceneTree
const W := 480
const H := 450
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var mk = scn.get_node("Markers")
	var solid = PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and terr.get_cell_atlas_coords(c).x<45: solid[idx(c.x,c.y)]=1
	var start_tile := Vector2i(-9,-9)
	var goal_tile := Vector2i(-9,-9)
	for c in mk.get_used_cells():
		var a = mk.get_cell_atlas_coords(c).x
		if a==18: start_tile=c
		if a==19: goal_tile=c
	print("start=", start_tile, " goal=", goal_tile)
	var sx:int = start_tile.x; var sy:int = start_tile.y
	var reach = PackedByteArray(); reach.resize(W*H)
	var q = PackedInt32Array([idx(sx,sy)]); reach[idx(sx,sy)]=1; var h=0
	var minx=999; var maxx=-999; var miny=999; var maxy=-999
	while h<q.size():
		var c=q[h]; h+=1; var cx=c%W; var cy=c/W
		minx=min(minx,cx); maxx=max(maxx,cx); miny=min(miny,cy); maxy=max(maxy,cy)
		for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
			var nx=cx+d.x; var ny=cy+d.y
			if nx<0 or nx>=W or ny<0 or ny>=H: continue
			var ni=idx(nx,ny)
			if solid[ni]==0 and reach[ni]==0: reach[ni]=1; q.append(ni)
	print("FLOOD (4-neighbour, gravity-ignoring) from start: cells=%d bbox=(%d,%d)-(%d,%d)"%[q.size(),minx,miny,maxx,maxy])
	print("goal reachable by flood (topology only)=%s"%str(reach[idx(goal_tile.x,goal_tile.y)]==1))
	quit()
