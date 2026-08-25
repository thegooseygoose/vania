extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_break=true
	# --- SLAM freeze phase ---
	p.global_position=Vector2(400,60); p.velocity=Vector2.ZERO
	await _step(2)
	Input.action_press("move_down"); await _step(3)
	print("FREEZE (0.05s in): slamming=%s ducking=%s vy=%.0f (want vy=0, ducking=true)" % [str(p.slamming), str(p.ducking), p.velocity.y])
	await _step(40)   # ~0.66s later -> crash
	print("CRASH (0.7s in): slamming=%s vy=%.0f (want vy~520)" % [str(p.slamming), p.velocity.y])
	Input.action_release("move_down")
	# --- CAMERA underground hide/reveal ---
	await _step(30)
	m.player.global_position = Vector2(400, 190); await _step(6)
	m._update_camera()
	print("on SURFACE: cam_y=%.0f (want <=0, underground hidden)  surface_floor=%d lvl_bottom=%.0f" % [m.cam_y, (m.FLOOR+2)*16, m.lvl_bottom])
	m.player.global_position = Vector2(400, m.lvl_bottom - 40); await _step(6)
	for i in range(20): m._update_camera(); await physics_frame
	print("in UNDERGROUND (y=%.0f): cam_y=%.0f (want >0, followed down)" % [m.player.global_position.y, m.cam_y])
	print("DONE"); quit()
