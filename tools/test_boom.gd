extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_boomerang=true; p.has_grapple=true
	# B (boomerang action) throws even near a grab point
	var gp=m.grab_points[0].global_position
	p.global_position=gp+Vector2(0,60); p.velocity=Vector2.ZERO; await _step(3)
	Input.action_press("boomerang"); await _step(2); Input.action_release("boomerang")
	print("B near grab -> boomerang=%s grappling=%s (want boomerang=true)" % [str(is_instance_valid(p.boomerang)), str(p.grappling)])
	print("DONE"); quit()
