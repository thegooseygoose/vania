extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(20): await physics_frame
	print("grab pt tile=(%d,%d)" % [int(m.grab_points[0].position.x/16), int(m.grab_points[0].position.y/16)])
	# for cols 120..175, print the topmost solid row (platform top) or '--' if empty column
	var line=""
	for x in range(120,176):
		var top=-99
		for y in range(-20,20):
			if m.terrain.get_cell_source_id(Vector2i(x,y))>=0: top=y; break
		line += ("%3d:%s " % [x, ("--" if top==-99 else str(top))])
		if (x-119)%8==0: print(line); line=""
	if line!="": print(line)
	print("DONE"); quit()
