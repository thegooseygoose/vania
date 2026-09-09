extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=12
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	# paint a 10x8 rectangle of SECTOR tiles (atlas 62) on the Markers layer, cols 20-29 rows 5-12
	for y in range(5,13):
		for x in range(20,30):
			m.markers_layer.set_cell(Vector2i(x,y), 0, Vector2i(62,0))
	# and a second sector 6x6 at cols 40-45 rows 2-7
	for y in range(2,8):
		for x in range(40,46):
			m.markers_layer.set_cell(Vector2i(x,y), 0, Vector2i(62,0))
	m._sector_rects.clear()
	m._build_painted_sectors()
	print("sectors built: %d"%m._sector_rects.size())
	for r in m._sector_rects: print("  rect %s (tiles: x %d-%d, y %d-%d)"%[str(r), int(r.position.x/16), int((r.position.x+r.size.x)/16)-1, int(r.position.y/16), int((r.position.y+r.size.y)/16)-1])
	# check cells erased
	var left=0
	for c in m.markers_layer.get_used_cells():
		if m.markers_layer.get_cell_atlas_coords(c).x==62: left+=1
	print("sector tiles remaining after read (should be 0): %d"%left)
	quit()
