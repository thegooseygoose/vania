extends SceneTree
const W:=44; const H:=24
func idx(x:int,y:int)->int: return y*W+x
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level29.tscn").instantiate()
	var terr=scn.get_node("Terrain")
	var solid=PackedByteArray(); solid.resize(W*H)
	for c in terr.get_used_cells():
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H: solid[idx(c.x,c.y)]=1
	var ps=scn.get_node("Spawns/PlayerStart")
	var sx=int(ps.position.x/16.0); var sy=int(ps.position.y/16.0)-1
	var reach=PackedByteArray(); reach.resize(W*H)
	var q=PackedInt32Array([idx(sx,sy)]); reach[idx(sx,sy)]=1; var h=0
	while h<q.size():
		var c=q[h]; h+=1; var cx=c%W; var cy=c/W
		for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
			var nx=cx+d.x; var ny=cy+d.y
			if nx<0 or nx>=W or ny<0 or ny>=H: continue
			var ni=idx(nx,ny)
			if solid[ni]==0 and reach[ni]==0: reach[ni]=1; q.append(ni)
	var opent=0; var r=0
	for i in solid.size():
		if solid[i]==0: opent+=1
		if reach[i]==1: r+=1
	var goal_ok = reach[idx(41,19)]==1
	var morph_ok = reach[idx(16,19)]==1
	print("start=(%d,%d) reachable=%d/%d (%.0f%%)  GOAL_reachable=%s  morph_reachable=%s"%[sx,sy,r,opent,100.0*r/max(1,opent),str(goal_ok),str(morph_ok)])
	quit()
