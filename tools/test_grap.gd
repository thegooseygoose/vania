extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	# collect star ONLY, checking its main + position
	var star=null
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd") and c.shape=="star": star=c
	print("star node: pos=%s main_set=%s" % [str(star.position), str(star.main!=null)])
	p.global_position = star.global_position
	await _step(3)
	print("after touch: has_grapple=%s star_freed=%s" % [str(p.has_grapple), str(not is_instance_valid(star))])
	# grapple mechanic (force-enable to be safe)
	p.has_grapple = true
	var gp = m.grab_points[0].global_position
	p.global_position = gp + Vector2(30, 60); p.velocity=Vector2.ZERO
	await _step(2)
	Input.action_press("shoot"); await _step(2); Input.action_release("shoot")
	print("grapple started=%s target=%s" % [str(p.grappling), str(p.grapple_target)])
	await _step(20)
	print("hang: player=(%.0f,%.0f) grappling=%s" % [p.global_position.x, p.global_position.y, str(p.grappling)])
	Input.action_press("jump"); await _step(2)
	print("leap off: grappling=%s vy=%.0f" % [str(p.grappling), p.velocity.y])
	print("DONE"); quit()
