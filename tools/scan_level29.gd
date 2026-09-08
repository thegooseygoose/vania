extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level29.tscn").instantiate()
	var terr=scn.get_node("Terrain")
	var et=scn.get_node("EnemyTiles")
	var used=terr.get_used_cells()
	var minx=99999; var maxx=-99999; var miny=99999; var maxy=-99999
	for c in used:
		minx=min(minx,c.x); maxx=max(maxx,c.x); miny=min(miny,c.y); maxy=max(maxy,c.y)
	# count door tiles (26/27/28) on EnemyTiles
	var doors=[]
	for c in et.get_used_cells():
		var ax=et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: doors.append([c.x,c.y,ax])
	print("Terrain cells=%d  bounds x[%d..%d] y[%d..%d]"%[used.size(),minx,maxx,miny,maxy])
	print("door tiles found=%d"%doors.size())
	for d in doors: print("  door atlas %d at (%d,%d)"%[d[2],d[0],d[1]])
	# render an overview PNG of the WHOLE terrain (solid=blue, door=green)
	var gw=maxx+2; var gh=maxy+2
	var img=Image.create(gw,gh,false,Image.FORMAT_RGBA8)
	img.fill(Color(0.05,0.06,0.09))
	for c in used:
		img.set_pixel(c.x,c.y,Color(0.27,0.47,0.86))
	for d in doors:
		img.set_pixel(d[0],d[1],Color(0.3,1.0,0.4))
	img.save_png("res://tools/_lvl29_now.png")
	print("saved tools/_lvl29_now.png %dx%d"%[gw,gh])
	quit()
