extends SceneTree
## Fuzz-reproduce the "Level 5 permanently stops responding, camera too" report: boot Level5,
## hold right (occasionally jump), run many physics frames, and if the player's position stops
## changing for a long stretch while actors_frozen() is true, dump full freeze-related state.
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1
	# find level_num for file 21 (1-5)
	Main.debug_start_level = 5
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame
	print("booted level_file=%d player=%s" % [m._level_file, str(m.player != null)])
	if not m.player:
		quit(); return

	var last_pos: Vector2 = m.player.global_position
	var stuck_frames := 0
	var frame := 0
	while frame < 9000:
		frame += 1
		Input.action_press("move_right")
		if frame % 90 == 0:
			Input.action_press("jump")
		else:
			Input.action_release("jump")
		await physics_frame
		var pos: Vector2 = m.player.global_position
		var moved: bool = pos.distance_to(last_pos) > 0.05
		if not moved:
			stuck_frames += 1
		else:
			stuck_frames = 0
		last_pos = pos
		if stuck_frames == 120:   # ~2s with zero movement despite holding right
			print("=== STUCK at frame %d, pos=%s ===" % [frame, str(pos)])
			print("paused=%s actors_frozen=%s" % [str(m.paused), str(m.actors_frozen())])
			print("powerup_freeze_t=%.2f _cam_lock=%s" % [m.powerup_freeze_t, str(m._cam_lock)])
			print("player.dead=%s player.transforming=%s player.dashing=%s player.riderkicking=%s player.grappling=%s player.door_walk=%s" % [
				str(m.player.dead), str(m.player.transforming), str(m.player.dashing), str(m.player.riderkicking),
				str(m.player.grappling), str(m.player.door_walk)])
			print("cam_x=%.1f game_state=%s time_slow_t=%.2f" % [m.cam_x, m.game_state, m.time_slow_t])
	if stuck_frames < 120:
		print("did NOT reproduce a freeze in %d frames (final pos=%s)" % [frame, str(last_pos)])
	quit()
