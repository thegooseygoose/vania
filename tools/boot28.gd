extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=12   # play-slot 12 = Level Z (file 28)
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	print("level_file=%d player=%s pos=%s"%[m._level_file, str(m.player!=null), str(m.player.global_position) if m.player else "?"])
	quit()
