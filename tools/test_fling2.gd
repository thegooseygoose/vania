extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func measure(m, p, a, pump_frames):
	p.grappling=false; p.fling_t=0.0
	p.global_position=a+Vector2(50,10); p.velocity=Vector2.ZERO
	await _step(2)
	Input.action_press("grapple"); await _step(2); Input.action_release("grapple")
	# pump toward the LEFT (across) for pump_frames
	if pump_frames>0:
		Input.action_press("move_left"); await _step(pump_frames); Input.action_release("move_left")
	var vx=p.velocity.x
	Input.action_press("jump"); await _step(1); Input.action_release("jump")
	Input.action_press("move_left")
	var x0=p.global_position.x
	for i in range(48): await physics_frame
	Input.action_release("move_left")
	return [vx, x0 - p.global_position.x]
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	var r0=await measure(m,p,a,0)
	print("MINIMAL swing (jump right away): release vx=%.0f -> travelled %.0f px (%.1f tiles)" % [r0[0], r0[1], r0[1]/16.0])
	var r1=await measure(m,p,a,14)
	print("PUMPED swing (0.23s): release vx=%.0f -> travelled %.0f px (%.1f tiles)" % [r1[0], r1[1], r1[1]/16.0])
	print("DONE"); quit()
