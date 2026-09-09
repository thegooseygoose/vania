extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level28.tscn").instantiate()
	var terr=scn.get_node("Terrain")
	var et=scn.get_node_or_null("EnemyTiles")
	var used=terr.get_used_cells()
	var minx=999999;var maxx=-999999;var miny=999999;var maxy=-999999
	for c in used:
		minx=min(minx,c.x);maxx=max(maxx,c.x);miny=min(miny,c.y);maxy=max(maxy,c.y)
	# expand bounds a little for open border
	minx-=2;miny-=2;maxx+=2;maxy+=2
	var W=maxx-minx+1; var H=maxy-miny+1
	var solid={}
	for c in used:
		if terr.get_cell_atlas_coords(c).x<45: solid[c]=true   # solid terrain
	# door cells = boundaries too
	if et:
		for c in et.get_used_cells():
			var ax=et.get_cell_atlas_coords(c).x
			if ax>=26 and ax<=28: solid[c]=true
	# flood-fill open cells into rooms
	var seen={}
	var rooms=[]
	for c in used:
		pass
	# iterate all cells in bounds
	for y in range(miny,maxy+1):
		for x in range(minx,maxx+1):
			var cc=Vector2i(x,y)
			if solid.has(cc) or seen.has(cc): continue
			# BFS this open region
			var q=[cc]; seen[cc]=true; var rminx=x;var rmaxx=x;var rminy=y;var rmaxy=y; var n=0
			while q.size()>0:
				var p=q.pop_back(); n+=1
				rminx=min(rminx,p.x);rmaxx=max(rmaxx,p.x);rminy=min(rminy,p.y);rmaxy=max(rmaxy,p.y)
				for d in [Vector2i(1,0),Vector2i(-1,0),Vector2i(0,1),Vector2i(0,-1)]:
					var np=p+d
					if np.x<minx or np.x>maxx or np.y<miny or np.y>maxy: continue
					if solid.has(np) or seen.has(np): continue
					seen[np]=true; q.append(np)
			if n>=6:  # ignore tiny pockets
				rooms.append([n,rminx,rminy,rmaxx,rmaxy])
	print("open ROOMS found (flood, doors as walls): %d"%rooms.size())
	for r in rooms:
		print("  %d cells, tile bbox (%d,%d)-(%d,%d)"%[r[0],r[1],r[2],r[3],r[4]])
	quit()
