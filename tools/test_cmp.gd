extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	# NORMAL running jump: run in the air (open sky), measure horizontal from apex-launch to same height
	p.global_position=Vector2(400,60); p.velocity=Vector2(-p.RUN_MAX,0); p.facing=-1
	Input.action_press("run"); Input.action_press("move_left")
	await _step(4)
	var y0=p.global_position.y; var x0=p.global_position.x
	Input.action_press("jump"); await _step(16); Input.action_release("jump")
	# fly until back to start height
	for i in range(120):
		await physics_frame
		if p.global_position.y >= y0 and p.velocity.y>0: break
	Input.action_release("move_left"); Input.action_release("run")
	print("NORMAL running jump horizontal reach = %.1f tiles" % ((x0-p.global_position.x)/16.0))
	print("DONE"); quit()
