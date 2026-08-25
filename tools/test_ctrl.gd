extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true; p.has_boomerang=true
	var gp=m.grab_points[0].global_position
	# 1) grapple via Y (grapple action) near grab point
	p.global_position=gp+Vector2(0,60); p.velocity=Vector2.ZERO; p.grappling=false; await _step(2)
	Input.action_press("grapple"); await _step(2); Input.action_release("grapple")
	print("Y near grab -> grappling=%s (want true)" % str(p.grappling))
	# 2) Y away from grab point -> should do NOTHING (no boomerang)
	p.grappling=false; p.global_position=Vector2(1000,190); p.velocity=Vector2.ZERO; p.boomerang=null; await _step(3)
	Input.action_press("grapple"); await _step(2); Input.action_release("grapple")
	print("Y away -> boomerang=%s (want false/none)" % str(is_instance_valid(p.boomerang)))
	# 3) shoot (C) away -> boomerang
	await _step(3)
	Input.action_press("shoot"); await _step(2); Input.action_release("shoot")
	print("C away -> boomerang=%s (want true)" % str(is_instance_valid(p.boomerang)))
	# 4) shoot (C) near grab -> grapple (not boomerang)
	p.grappling=false; p.global_position=gp+Vector2(0,60); p.velocity=Vector2.ZERO; await _step(3)
	Input.action_press("shoot"); await _step(2); Input.action_release("shoot")
	print("C near grab -> grappling=%s (want true)" % str(p.grappling))
	print("DONE"); quit()
