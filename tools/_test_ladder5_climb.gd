extends SceneTree
## Real-engine test for the wide-alternating ladder: jump + drift toward the
## correct HALF of the shaft (not a precise centre point), landing anywhere on
## the wide platform.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var rows := [194, 191, 188, 185, 182, 179, 176, 173, 170, 167]
	var LEFT_START := 165 * 16 + 8    # comfortably inside 163-167
	var RIGHT_TARGET := 170 * 16 + 8  # comfortably inside 168-172

	m.player.global_position = Vector2(LEFT_START, 193 * 16 + 8)
	m.player.velocity = Vector2.ZERO
	m.player.jump_held = false
	for i in range(15): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor())

	for ri in range(1, rows.size()):
		var going_right: bool = ri % 2 == 1   # i=0 was LEFT, so ri=1 target is RIGHT, alternating
		var target_y: float = float(rows[ri] - 1) * 16 + 8
		var boundary: float = 168.0 * 16.0   # left/right half boundary (world x)
		var drift_target: float = boundary + (10.0 if going_right else -10.0)  # just past the seam
		m.player.jump_held = false
		Input.action_release("move_left"); Input.action_release("move_right")
		Input.action_press("jump")
		var frame := 0
		var arrived := false
		var started := false
		var released := false
		while frame < 150:
			frame += 1
			if m.player.velocity.y < 0.0: started = true
			if started and m.player.velocity.y >= 0.0 and not released:
				Input.action_release("jump"); released = true
			if going_right: Input.action_press("move_right"); Input.action_release("move_left")
			else: Input.action_press("move_left"); Input.action_release("move_right")
			var past_seam: bool = (m.player.global_position.x > drift_target) if going_right else (m.player.global_position.x < drift_target)
			if past_seam:
				Input.action_release("move_left"); Input.action_release("move_right")
			await physics_frame
			if ri == -1 and frame % 5 == 0:
				print("    f=%d pos=%s vel=%s on_floor=%s" % [frame, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			if m.player.is_on_floor() and absf(m.player.global_position.y - target_y) < 10.0:
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
