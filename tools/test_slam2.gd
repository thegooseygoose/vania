extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_break=true
	# high in the air, hold DOWN (mimics holding down through a jump) then slam
	p.global_position=Vector2(400,60); p.velocity=Vector2.ZERO
	await _step(2)
	Input.action_press("move_down")
	await _step(2)
	print("mid-slam frame A: slamming=%s ducking=%s col_h=%.0f vy=%.0f" % [str(p.slamming), str(p.ducking), p.col_size.y, p.velocity.y])
	await _step(2)
	print("mid-slam frame B: slamming=%s ducking=%s col_h=%.0f vy=%.0f" % [str(p.slamming), str(p.ducking), p.col_size.y, p.velocity.y])
	Input.action_release("move_down")
	print("DONE"); quit()
