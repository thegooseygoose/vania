extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	p.global_position=a+Vector2(60,0); p.velocity=Vector2.ZERO; await _step(2)
	Input.action_press("grapple"); await _step(2); Input.action_release("grapple")
	await _step(3)
	print("attached: grappling=%s rope=%.0f dist=%.0f" % [str(p.grappling), p.rope_len, p.global_position.distance_to(a)])
	# swing for a bit, track that it stays on the rope and arcs
	var samples=[]
	for i in range(24):
		await physics_frame
		if i%6==0: samples.append("(%.0f,%.0f d%.0f)" % [p.global_position.x-a.x, p.global_position.y-a.y, p.global_position.distance_to(a)])
	print("arc (rel to anchor): ", samples)
	print("still grappling=%s" % str(p.grappling))
	print("DONE"); quit()
