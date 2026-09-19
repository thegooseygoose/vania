extends SceneTree
## Tests each rung-to-rung hop on the widened zigzag ladder IN ISOLATION (fresh
## teleport + settle each time), so one hop's bot-timing quirk can't cascade
## into false failures on later hops.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var rows := [194, 191, 188, 185, 182, 179, 176, 173, 170, 167]
	var LEFT_C := 165 * 16 + 8    # inside 163-167
	var RIGHT_C := 170 * 16 + 8   # inside 168-172
	var boundary := 168.0 * 16.0

	var all_ok := true
	for i in range(rows.size() - 1):
		var from_row: int = rows[i]
		var to_row: int = rows[i + 1]
		var from_x: float = LEFT_C if i % 2 == 0 else RIGHT_C
		var going_right: bool = (i % 2 == 0)   # even i started LEFT -> going to RIGHT
		var target_y: float = float(to_row - 1) * 16 + 8
		var drift_target: float = boundary + (10.0 if going_right else -10.0)

		m.player.global_position = Vector2(from_x, float(from_row - 1) * 16 + 8)
		m.player.velocity = Vector2.ZERO
		m.player.jump_held = false
		Input.action_release("move_left"); Input.action_release("move_right"); Input.action_release("jump")
		for f in range(15): await physics_frame

		Input.action_press("jump")
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
			var past_seam: bool = (m.player.global_position.x > drift_target) if going_right else (m.player.global_position.x < drift_target)
			if past_seam:
				Input.action_release("move_left"); Input.action_release("move_right")
			await physics_frame
			if m.player.is_on_floor() and absf(m.player.global_position.y - target_y) < 10.0:
				arrived = true
				break
			if m.player.global_position.y > (from_row + 6) * 16:
				break
		Input.action_release("move_left"); Input.action_release("move_right"); Input.action_release("jump")
		if arrived:
			print("OK  hop %d: row %d -> row %d (frames=%d) final pos=%s" % [i, from_row, to_row, frame, str(m.player.global_position)])
		else:
			all_ok = false
			print("FAIL hop %d: row %d -> row %d, final pos=%s vel=%s on_floor=%s" %
				[i, from_row, to_row, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])

	print("ALL_OK=%s" % str(all_ok))
	quit()
