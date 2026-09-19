extends SceneTree
## Focused test of JUST the segment where every full-path attempt kept failing (waypoints 6-12,
## near spawn/morph): "35,207 -> 34,207 -> 33,207 -> 32,207 -> 32,204 -> 31,203 -> 31,201". Uses a
## STOP-THEN-JUMP state machine (fully kill horizontal velocity before jumping) instead of
## continuously chasing the next point, to rule out momentum-overshoot as the cause.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var wps := [Vector2(35*16+8,207*16+8), Vector2(34*16+8,207*16+8), Vector2(33*16+8,207*16+8),
		Vector2(32*16+8,207*16+8), Vector2(32*16+8,204*16+8), Vector2(31*16+8,203*16+8), Vector2(31*16+8,201*16+8)]
	m.player.global_position = wps[0]
	m.player.velocity = Vector2.ZERO
	for i in range(10): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor())

	for wi in range(1, wps.size()):
		var target: Vector2 = wps[wi]
		print("--- heading to waypoint %d: %s ---" % [wi, str(target)])
		var frame := 0
		var arrived := false
		while frame < 400:
			frame += 1
			var d: Vector2 = target - m.player.global_position
			if absf(d.x) > 3.0:
				if d.x > 0: Input.action_press("move_right"); Input.action_release("move_left")
				else: Input.action_press("move_left"); Input.action_release("move_right")
				Input.action_release("jump")
			else:
				# aligned horizontally: stop, then jump straight up if target is higher
				Input.action_release("move_left"); Input.action_release("move_right")
				if d.y < -6.0:
					Input.action_press("jump")
				else:
					Input.action_release("jump")
			await physics_frame
			if frame % 20 == 0:
				print("  f=%d pos=%s vel=%s on_floor=%s" % [frame, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			if m.player.global_position.distance_to(target) < 10.0:
				arrived = true
				break
			if m.player.global_position.y > 216*16:
				print("  FELL TOO FAR — pos=%s" % str(m.player.global_position))
				quit(1)
				return
		print("  result: arrived=%s final pos=%s" % [str(arrived), str(m.player.global_position)])
		if not arrived:
			print("FAILED to reach waypoint %d" % wi)
			quit(1)
			return
	print("SUCCESS: cleared the whole segment cleanly")
	quit()
