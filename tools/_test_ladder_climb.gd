extends SceneTree
## Real-engine test: drives the player up the rebuilt vertical jump-ladder
## (x166-169, rungs every 3 rows from y194 to y167) using ACTUAL jump input.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var rows := [194, 190, 186, 182, 178, 174, 170]
	var cx := 167 * 16 + 8   # centre of the 166-169 ladder column

	# stand on the bottom rung (solid at row 194 -> feet rest at row194 top, stand center y=193)
	m.player.global_position = Vector2(cx, 193 * 16 + 8)
	m.player.velocity = Vector2.ZERO
	m.player.jump_held = false
	for i in range(20): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor(), " jump_held=", m.player.jump_held)
	print("  riding=", m.player.riding, " dead=", m.player.dead, " start_delay=", m.start_delay,
		" paused=", m.paused, " cam_lock=", m._cam_lock, " powerup_freeze_t=", m.powerup_freeze_t,
		" door_walk=", m.player.door_walk, " morphed=", m.player.morphed)

	for ri in range(1, rows.size()):
		var target_y: float = float(rows[ri] - 1) * 16 + 8
		Input.action_release("move_left"); Input.action_release("move_right")
		m.player.jump_held = false
		Input.action_press("jump")
		var frame := 0
		var arrived := false
		var released := false
		var started := false
		while frame < 150:
			frame += 1
			if m.player.velocity.y < 0.0: started = true
			# hold jump the whole way up for max height; release only once actually falling
			if started and m.player.velocity.y >= 0.0 and not released:
				Input.action_release("jump"); released = true
			await physics_frame
			if frame <= 5 or frame % 15 == 0:
				print("    f=%d pos=%s vel=%s on_floor=%s jump_held=%s" %
					[frame, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor()), str(m.player.jump_held)])
			if m.player.global_position.y <= target_y + 4.0 and m.player.is_on_floor():
				arrived = true
				break
			if m.player.global_position.y > (194 + 6) * 16:
				print("FELL TOO FAR climbing to rung %d (row %d) pos=%s" % [ri, rows[ri], str(m.player.global_position)])
				quit(1)
				return
		if not arrived:
			print("STUCK reaching rung %d (row %d): final pos=%s vel=%s on_floor=%s" %
				[ri, rows[ri], str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			quit(1)
			return
		print("  reached rung %d (row %d) pos=%s" % [ri, rows[ri], str(m.player.global_position)])
	Input.action_release("jump")
	print("SUCCESS: climbed the whole ladder, final pos=%s" % str(m.player.global_position))
	quit()
