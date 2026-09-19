extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var hops := [
		{"from_x": 169 * 16 + 8, "from_y": (167 - 1) * 16 + 8, "to_x": 165 * 16 + 8, "to_y": (164 - 1) * 16 + 8},
		{"from_x": 165 * 16 + 8, "from_y": (164 - 1) * 16 + 8, "to_x": 168 * 16 + 8, "to_y": (161 - 1) * 16 + 8},
	]
	var all_ok := true
	for h in hops:
		m.player.global_position = Vector2(h["from_x"], h["from_y"])
		m.player.velocity = Vector2.ZERO
		m.player.jump_held = false
		Input.action_release("move_left"); Input.action_release("move_right"); Input.action_release("jump")
		for f in range(15): await physics_frame
		print("  settled pos=%s on_floor=%s" % [str(m.player.global_position), str(m.player.is_on_floor())])

		var going_right: bool = h["to_x"] > h["from_x"]
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
			await physics_frame
			if frame % 5 == 0:
				print("    f=%d pos=%s vel=%s on_floor=%s" % [frame, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			if m.player.is_on_floor() and absf(m.player.global_position.y - h["to_y"]) < 10.0:
				arrived = true
				break
			if m.player.global_position.y > h["from_y"] + 100:
				break
		Input.action_release("move_left"); Input.action_release("move_right")
		if arrived:
			print("OK hop from y=%.0f to y=%.0f, final pos=%s" % [h["from_y"], h["to_y"], str(m.player.global_position)])
		else:
			all_ok = false
			print("FAIL hop from y=%.0f to y=%.0f, final pos=%s vel=%s on_floor=%s" %
				[h["from_y"], h["to_y"], str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
	print("ALL_OK=%s" % str(all_ok))
	quit()
