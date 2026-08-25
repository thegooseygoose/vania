extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	p.global_position=Vector2(400,80); p.velocity=Vector2.ZERO
	await _step(6)
	# run right
	Input.action_press("run"); Input.action_press("move_right")
	await _step(120)
	var runspd = p.velocity.x
	Input.action_release("run")
	await _step(120)
	var walkspd = p.velocity.x
	Input.action_release("move_right")
	print("run max=%.1f (want ~77)  walk max=%.1f (want ~47)" % [runspd, walkspd])
	# standing jump height
	await _step(20)
	var y0=p.global_position.y
	Input.action_press("jump"); await _step(18); Input.action_release("jump")
	var peak=y0
	for i in range(40): await physics_frame; peak=min(peak,p.global_position.y)
	print("standing jump rise=%.1f px (%.1f tiles)  [was ~55px]" % [y0-peak, (y0-peak)/16.0])
	print("DONE"); quit()
