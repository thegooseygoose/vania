extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 5
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame
	print("lvl_left=%.1f lvl_right=%.1f LW=%d LH=%d lvl_top=%.1f lvl_bottom=%.1f" % [
		m.lvl_left, m.lvl_right, m.LW, m.LH, m.lvl_top, m.lvl_bottom])
	quit()
