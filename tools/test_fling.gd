extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	# start up-and-right so it swings down through the bottom picking up speed
	p.global_position=a+Vector2(70,-40); p.velocity=Vector2.ZERO; await _step(2)
	Input.action_press("grapple"); await _step(2); Input.action_release("grapple")
	# swing until it's moving fast leftward (near bottom of arc)
	var best=0.0
	for i in range(40):
		await physics_frame
		if p.velocity.x < best: best=p.velocity.x   # most-negative (leftward) vx
		if p.velocity.x < -300 and p.global_position.y > a.y+40:
			break
	var vx_release = p.velocity.x
	# release with jump, hold LEFT (fling direction)
	Input.action_press("jump"); await _step(1); Input.action_release("jump")
	Input.action_press("move_left")
	var x0=p.global_position.x
	for i in range(45): await physics_frame
	var travelled = x0 - p.global_position.x
	Input.action_release("move_left")
	print("release vx=%.0f (Mario run max=77)  -> travelled %.0f px (%.1f tiles) in 0.75s while holding the fly dir" % [vx_release, travelled, travelled/16.0])
	print("DONE"); quit()
