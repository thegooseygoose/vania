extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _press(a): Input.action_press(a); await _step(2); Input.action_release(a); await _step(2)

func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay=0.0; m.fade_alpha=0.0
	var p = m.player
	var bike=null
	for c in m.level.get_children():
		if c.get_script()==load("res://bike.gd"): bike=c

	print("bike action exists: ", InputMap.has_action("bike"))

	# stand right on the bike WITHOUT pressing -> must NOT auto-mount
	p.global_position = bike.global_position
	p.velocity = Vector2.ZERO
	await _step(8)
	print("standing on bike, no press: riding=%s (want false — no auto-mount)" % str(p.riding))

	# press the bike button while in range -> mount
	await _press("bike")
	print("after bike-press near it: riding=%s bike.ridden=%s (want true/true)" % [str(p.riding), str(bike.ridden)])

	# press again -> dismount
	await _press("bike")
	print("after bike-press again: riding=%s bike.ridden=%s (want false/false)" % [str(p.riding), str(bike.ridden)])

	# stand on it again, no press -> still no auto-mount
	p.global_position = bike.global_position; p.velocity=Vector2.ZERO
	await _step(8)
	print("back on bike, no press: riding=%s (want false)" % str(p.riding))

	# press far away -> nothing to mount
	p.global_position = bike.global_position + Vector2(300,0); await _step(2)
	await _press("bike")
	print("press far from any bike: riding=%s (want false)" % str(p.riding))

	print("DONE")
	quit()
