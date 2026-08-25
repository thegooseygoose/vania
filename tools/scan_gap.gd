extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(20): await physics_frame
	# find floor gaps (no solid in rows 13/14) between cols 100 and 200
	var gaps=[]; var ingap=false; var gs=0
	for x in range(100,210):
		var solid = m.terrain.get_cell_source_id(Vector2i(x,13))>=0 or m.terrain.get_cell_source_id(Vector2i(x,14))>=0
		# also check any solid in rows 10..16 (platforms may be higher)
		var anysolid=false
		for y in range(8,18):
			if m.terrain.get_cell_source_id(Vector2i(x,y))>=0: anysolid=true; break
		if not anysolid and not ingap: ingap=true; gs=x
		elif anysolid and ingap: ingap=false; gaps.append([gs,x-1,x-gs])
	print("grab point col=%d" % int(m.grab_points[0].position.x/16) if m.grab_points.size()>0 else -1)
	print("floor gaps (col_start, col_end, width_tiles): ", gaps)
	print("DONE"); quit()
