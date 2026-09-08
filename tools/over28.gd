extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level28.tscn").instantiate()
	var terr=scn.get_node("Terrain")
	var used=terr.get_used_cells()
	var minx=999999; var maxx=-999999; var miny=999999; var maxy=-999999
	for c in used:
		minx=min(minx,c.x); maxx=max(maxx,c.x); miny=min(miny,c.y); maxy=max(maxy,c.y)
	print("Terrain: %d cells, bounds x[%d..%d] y[%d..%d] (%dx%d tiles)"%[used.size(),minx,maxx,miny,maxy,maxx-minx+1,maxy-miny+1])
	# tile histograms per layer
	for lname in ["Terrain","Markers","Powerups","EnemyTiles","CoinTiles"]:
		var n=scn.get_node_or_null(lname)
		if n==null: continue
		var hist={}
		for c in n.get_used_cells(): var ax=n.get_cell_atlas_coords(c).x; hist[ax]=hist.get(ax,0)+1
		if hist.size()>0:
			var ks=hist.keys(); ks.sort()
			var parts=[]
			for k in ks: parts.append("%d:%d"%[k,hist[k]])
			print("  %s -> %s"%[lname, ", ".join(parts)])
	var sp=scn.get_node_or_null("Spawns/PlayerStart")
	print("PlayerStart: %s"%(str(sp.position) if sp else "NONE"))
	# render overview (terrain blue, markers gold, powerups green, doors cyan, other enemytiles red)
	var pad=1
	var gw=maxx-minx+1+pad*2; var gh=maxy-miny+1+pad*2
	var img=Image.create(gw,gh,false,Image.FORMAT_RGBA8); img.fill(Color(0.05,0.06,0.09))
	for c in terr.get_used_cells(): img.set_pixel(c.x-minx+pad,c.y-miny+pad,Color(0.27,0.47,0.86))
	var pw=scn.get_node_or_null("Powerups")
	if pw: for c in pw.get_used_cells(): img.set_pixel(c.x-minx+pad,c.y-miny+pad,Color(0.4,0.9,0.5))
	var mk=scn.get_node_or_null("Markers")
	if mk: for c in mk.get_used_cells(): img.set_pixel(c.x-minx+pad,c.y-miny+pad,Color(1,0.85,0.2))
	var et=scn.get_node_or_null("EnemyTiles")
	if et: for c in et.get_used_cells():
		var ax=et.get_cell_atlas_coords(c).x
		var col=Color(1,0.3,0.3)
		if ax>=26 and ax<=28: col=Color(0.4,0.8,1)
		img.set_pixel(c.x-minx+pad,c.y-miny+pad,col)
	var scale=max(1, int(700.0/max(gw,gh)))
	img.resize(gw*scale,gh*scale,Image.INTERPOLATE_NEAREST).save("res://tools/_lz_now.png")
	print("overview saved %dx%d scale %d"%[gw,gh,scale])
	quit()
