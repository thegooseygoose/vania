extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	m.filter_mode = 3
	m._apply_filter()
	for i in range(10): await RenderingServer.frame_post_draw
	var img := get_root().get_texture().get_image()
	if img:
		img.save_png("res://tools/_shot_gameboy.png")
		print("saved, size=", img.get_size())
	else:
		print("no image")
	quit()
