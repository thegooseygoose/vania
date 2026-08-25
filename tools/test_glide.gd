extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	# swing then release
	p.global_position=a+Vector2(45,10); p.velocity=Vector2.ZERO; await _step(2)
	Input.action_press("grapple"); await _step(2)
	Input.action_press("move_left"); await _step(12)
	Input.action_release("grapple"); await _step(1)
	var x0=p.global_position.x; var y0=p.global_position.y
	# glide, holding left, sample every 20 frames
	for s in range(5):
		await _step(20)
		print("  t=%.1fs  dx=%.1f tiles  dy=%.1f tiles  vy=%.0f" % [(s+1)*20/60.0, (x0-p.global_position.x)/16.0, (p.global_position.y-y0)/16.0, p.velocity.y])
	Input.action_release("move_left")
	print("DONE"); quit()
