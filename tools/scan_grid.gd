extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(20): await physics_frame
	# dump terrain atlas grid for cols 194..208, rows 0..14
	for y in range(0,15):
		var row=""
		for x in range(194,209):
			var src=m.terrain.get_cell_source_id(Vector2i(x,y))
			if src<0: row+=" ."
			else: row+="%2d" % m.terrain.get_cell_atlas_coords(Vector2i(x,y)).x
		print("y%2d: %s" % [y, row])
	# also list every tile_renderer child + any node with flagpole_preview script
	for n in m.get_children():
		print("main child: ", n.name, " ", n.get_class(), " script=", n.get_script())
	print("DONE"); quit()
