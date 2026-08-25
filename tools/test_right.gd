extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_grapple=true
	var a=m.grab_points[0].global_position
	# open sky so nothing blocks; start left of anchor, swing RIGHT
	p.global_position=a+Vector2(-45,10); p.velocity=Vector2.ZERO; await _step(2)
	Input.action_press("grapple"); await _step(2)
	Input.action_press("move_right"); await _step(14)
	Input.action_release("grapple"); await _step(1)
	print("LAUNCH velocity=(%.0f,%.0f)  (want big +x, small -y, NOT big -y)" % [p.velocity.x, p.velocity.y])
	var x0=p.global_position.x; var y0=p.global_position.y
	for s in range(4):
		await _step(15)
		print("  +%.2fs: dx=%.1f tiles (right)  dy=%.1f tiles (down+)" % [(s+1)*15/60.0, (p.global_position.x-x0)/16.0, (p.global_position.y-y0)/16.0])
	print("DONE"); quit()
