extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var scn=load("res://Level29.tscn").instantiate()
	var terr=scn.get_node("Terrain"); var mk=scn.get_node("Markers"); var pw=scn.get_node("Powerups"); var et=scn.get_node("EnemyTiles")
	var img=Image.create(44,24,false,Image.FORMAT_RGBA8); img.fill(Color(0.06,0.08,0.12))
	for c in terr.get_used_cells(): img.set_pixel(c.x,c.y,Color(0.27,0.47,0.86))
	for c in pw.get_used_cells(): img.set_pixel(c.x,c.y,Color(0.4,0.9,0.5))   # morph=green
	for c in mk.get_used_cells(): img.set_pixel(c.x,c.y,Color(1,0.85,0.2))     # goal=gold
	for c in et.get_used_cells():
		var ax=et.get_cell_atlas_coords(c).x
		var col=Color(1,0.3,0.3)
		if ax>=26 and ax<=28: col=Color(0.5,0.8,1)   # door=lightblue
		img.set_pixel(c.x,c.y,col)
	img.resize(44*14,24*14,Image.INTERPOLATE_NEAREST).save("res://tools/_brinstar_clean.png")
	print("overview saved")
	quit()
