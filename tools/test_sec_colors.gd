extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=12
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	var ml=m.markers_layer
	# two TOUCHING boxes, different colours: cyan cols 5-9, magenta cols 10-14 (share the 9|10 edge), rows 3-8
	for y in range(3,9):
		for x in range(5,10): ml.set_cell(Vector2i(x,y),0,Vector2i(62,0))
		for x in range(10,15): ml.set_cell(Vector2i(x,y),0,Vector2i(63,0))
	# two TOUCHING boxes, SAME colour (should MERGE): lime cols 20-24 and 25-29, rows 3-8
	for y in range(3,9):
		for x in range(20,30): ml.set_cell(Vector2i(x,y),0,Vector2i(64,0))
	m._sector_rects.clear(); m._build_painted_sectors()
	print("sectors: %d (expect 3: cyan, magenta, one merged lime)"%m._sector_rects.size())
	for r in m._sector_rects: print("  tiles x %d-%d y %d-%d"%[int(r.position.x/16), int((r.position.x+r.size.x)/16)-1, int(r.position.y/16), int((r.position.y+r.size.y)/16)-1])
	quit()
