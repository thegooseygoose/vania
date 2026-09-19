extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(10): await physics_frame
	var Enemy = load("res://enemy.gd")
	var e = Enemy.new(); e.main = m
	print("_zoom_solid over atlas67 (28,200) = ", e._zoom_solid(Vector2i(28, 200)), " (expect true)")
	print("_zoom_solid over atlas68 (29,205) = ", e._zoom_solid(Vector2i(29, 205)), " (expect true)")
	quit()
