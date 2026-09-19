extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var rows := [194, 192, 190, 188, 186, 184, 182, 180, 178, 176, 174, 172, 170, 168, 166]
	var LEFT_C := 165 * 16 + 8    # centre of 164-166
	var RIGHT_C := 168 * 16 + 8   # centre of 167-169

	m.player.global_position = Vector2(LEFT_C, 193 * 16 + 8)
	m.player.velocity = Vector2.ZERO
	m.player.jump_held = false
	for i in range(15): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor())

	for ri in range(1, rows.size()):
		var target_x: float = RIGHT_C if ri % 2 == 1 else LEFT_C
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
			if absf(target_x - m.player.global_position.x) < 4.0:
				Input.action_release("move_left"); Input.action_release("move_right")
			await physics_frame
			if frame % 3 == 0 and ri == 1:
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
