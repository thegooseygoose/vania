extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	p.global_position=a+Vector2(50,10); p.velocity=Vector2.ZERO; await _step(2)
	# HOLD grapple (Y) the whole time
	Input.action_press("grapple")
	await _step(2)
	print("attached (holding Y): grappling=%s" % str(p.grappling))
	# pump left while holding
	Input.action_press("move_left"); await _step(16)
	print("swinging: grappling=%s vx=%.0f" % [str(p.grappling), p.velocity.x])
	# RELEASE Y -> should launch
	Input.action_release("grapple")
	await _step(1)
	print("released Y: grappling=%s launch vel=(%.0f,%.0f)" % [str(p.grappling), p.velocity.x, p.velocity.y])
	var x0=p.global_position.x
	for i in range(48): await physics_frame
	Input.action_release("move_left")
	print("travelled %.0f px (%.1f tiles) after release" % [x0-p.global_position.x, (x0-p.global_position.x)/16.0])
	print("DONE"); quit()
