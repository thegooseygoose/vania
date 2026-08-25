extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	print("doors=%d switches=%d" % [m.doors.size(), m.door_switches.size()])
	var sw=m.door_switches[0]; var dr=m.doors[0]
	var p=m.player; p.has_boomerang=true
	# 1) player walks ONTO the switch -> should NOT trigger (only boomerang can)
	p.global_position=sw.global_position; await _step(4)
	print("player touched switch: triggered=%s (want false)" % str(sw.triggered))
	# 2) throw boomerang toward the switch
	p.global_position=sw.global_position + Vector2(-40, 0); p.velocity=Vector2.ZERO; p.facing=1
	await _step(3)
	Input.action_press("boomerang"); await _step(2); Input.action_release("boomerang")
	for i in range(50): await physics_frame
	print("after boomerang: switch triggered=%s (want true)  door opened=%s (want true)" % [str(sw.triggered), str(dr.opened)])
	print("DONE"); quit()
