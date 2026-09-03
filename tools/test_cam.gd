extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(50); m.start_delay=0.0; m.fade_alpha=0.0
	m.player.global_position.x = 800.5
	await _step(5)
	print("cam_x=%.3f camera.x=%.3f (should be fractional-capable, not integer-snapped)" % [m.cam_x, m.camera.position.x])
	print("DONE"); quit()
