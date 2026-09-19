extends SceneTree
## Real-engine test: climbs the alternating-side ladder via actual jump+aim input.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var rows := [194, 191, 188, 185, 182, 179, 176, 173, 170, 167]
	var LA := 164 * 16 + 8   # centre of left rung (163-165)
	var LB := 171 * 16 + 8   # centre of right rung (170-172)

	m.player.global_position = Vector2(LA, 193 * 16 + 8)
	m.player.velocity = Vector2.ZERO
	m.player.jump_held = false
	for i in range(15): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor())

	for ri in range(1, rows.size()):
		var target_x: float = LA if ri % 2 == 0 else LB
		var target_y: float = float(rows[ri] - 1) * 16 + 8
		m.player.jump_held = false
		Input.action_press("jump")
		var going_right: bool = target_x > m.player.global_position.x
		if going_right: Input.action_press("move_right"); Input.action_release("move_left")
		else: Input.action_press("move_left"); Input.action_release("move_right")
		var frame := 0
		var arrived := false
		var started := false
		var released := false
		while frame < 150:
			frame += 1
			if m.player.velocity.y < 0.0: started = true
			if started and m.player.velocity.y >= 0.0 and not released:
				Input.action_release("jump"); released = true
			if absf(target_x - m.player.global_position.x) < 6.0:
				Input.action_release("move_left"); Input.action_release("move_right")
			await physics_frame
			if ri == 1 and frame % 5 == 0:
				print("    f=%d pos=%s vel=%s on_floor=%s" % [frame, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			if m.player.global_position.distance_to(Vector2(target_x, target_y)) < 10.0 and m.player.is_on_floor():
				arrived = true
				break
			if m.player.global_position.y > (194 + 6) * 16:
				print("FELL TOO FAR climbing to rung %d (row %d) pos=%s" % [ri, rows[ri], str(m.player.global_position)])
				quit(1)
				return
		Input.action_release("move_left"); Input.action_release("move_right")
		if not arrived:
			print("STUCK reaching rung %d (row %d): final pos=%s vel=%s on_floor=%s" %
				[ri, rows[ri], str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			quit(1)
			return
		print("  reached rung %d (row %d) pos=%s" % [ri, rows[ri], str(m.player.global_position)])
	print("SUCCESS: climbed the whole ladder, final pos=%s" % str(m.player.global_position))
	quit()
