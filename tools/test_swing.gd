extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	# start to the RIGHT of the anchor, level with it -> should swing DOWN then across
	p.global_position=a+Vector2(60,0); p.velocity=Vector2.ZERO; await _step(2)
	Input.action_press("grapple"); await _step(1); Input.action_release("grapple")
	print("attached: rope_len=%.1f grappling=%s" % [p.rope_len, str(p.grappling)])
	var minx=999999.0; var maxy=-999999.0
	for i in range(30):
		await physics_frame
		var d=p.global_position.distance_to(a)
		minx=min(minx, p.global_position.x)
		maxy=max(maxy, p.global_position.y)
	print("after swing: dist-to-anchor stays ~rope? d=%.1f (want ~%.0f)  swung down maxY=%.0f (start=%.0f)  leftmost x=%.0f (start=%.0f)" % [p.global_position.distance_to(a), p.rope_len, maxy, a.y, minx, a.x+60])
	# release with jump -> keeps momentum
	Input.action_press("jump"); await _step(2); Input.action_release("jump")
	print("released: grappling=%s vel=(%.0f,%.0f)" % [str(p.grappling), p.velocity.x, p.velocity.y])
	print("DONE"); quit()
