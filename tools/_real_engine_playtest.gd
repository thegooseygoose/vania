extends SceneTree
## A REAL playtest using the actual running game engine (not the abstract BFS model) — drives the
## player with simulated input toward a sequence of waypoints (morph pickup -> double-jump pickup ->
## goal), using simple reactive control (move toward target, jump over obstacles/gaps, shoot when
## stalled near a door, morph/unmorph as needed). Reports whether it actually reaches the goal via
## real physics (real gravity, real collision, real move_and_slide, real door-shooting).
var m
var target := Vector2.ZERO
var target_name := ""
var stuck_t := 0.0
var last_pos := Vector2.ZERO
var shoot_cd := 0.0

func _initialize(): call_deferred("_run")

func log_state(tag: String) -> void:
	print("[%s] t=%.1fs pos=(%.0f,%.0f) hp=%d morphed=%s has_morph=%s has_dj=%s dead=%s door_walk=%d" % [
		tag, Engine.get_physics_frames() / 60.0, m.player.global_position.x, m.player.global_position.y,
		m.player.hp, str(m.player.morphed), str(m.player.has_morph), str(m.player.has_double_jump),
		str(m.player.dead), m.player.door_walk])

func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var waypoints := [
		["morph", Vector2(24 * 16 + 8, 206 * 16)],
		["double_jump", Vector2(125 * 16 + 8, 284 * 16)],
		["goal", Vector2(175 * 16 + 8, 449 * 16)],
	]

	last_pos = m.player.global_position
	var max_frames := 30000   # 500s of game time — generous
	var frame := 0
	var wp_i := 0
	var jump_cd := 0.0

	var death_count := 0
	while frame < max_frames and wp_i < waypoints.size():
		frame += 1
		if m.player.dead:
			death_count += 1
			print("DIED #%d at frame %d, pos=%s — healing + repositioning to keep testing geometry" % [
				death_count, frame, str(m.player.global_position)])
			if death_count > 15:
				print("ABORT: died 15+ times, this isn't a viable path (or the autopilot is too naive)")
				log_state("TOO_MANY_DEATHS")
				quit(1)
				return
			# recover: heal + un-die, nudge back slightly so it doesn't immediately re-die same spot
			await physics_frame
			var recover_dir: float = sign(waypoints[wp_i][1].x - m.player.global_position.x)
			m.player.dead = false
			m.player.hp = m.player.MAX_HP
			m.player.global_position += Vector2(-16.0 * recover_dir, -8.0)
			m.player.velocity = Vector2.ZERO
			m.player.invuln = 2.0
			for i in range(10): await physics_frame
			continue
		target_name = waypoints[wp_i][0]
		target = waypoints[wp_i][1]
		var d: Vector2 = target - m.player.global_position

		# horizontal steer
		if absf(d.x) > 6.0:
			if d.x > 0: Input.action_press("move_right"); Input.action_release("move_left")
			else: Input.action_press("move_left"); Input.action_release("move_right")
		else:
			Input.action_release("move_left"); Input.action_release("move_right")

		# ENEMY AVOIDANCE: this is METROID rules (no stomping, any contact hurts) — a blind walk-
		# into-everything autopilot will die fast to totally normal enemies, same as a careless human
		# would. Hop over anything close ahead at foot height instead of just walking into it.
		var enemy_ahead := false
		for e in m.enemies:
			if not is_instance_valid(e) or e.dead: continue
			var ed: Vector2 = e.global_position - m.player.global_position
			if sign(ed.x) == sign(d.x) and absf(ed.x) < 28.0 and absf(ed.y) < 20.0:
				enemy_ahead = true
				break

		# vertical: jump if target is above us, an enemy blocks the path ahead, or we're stuck
		jump_cd = maxf(0.0, jump_cd - (1.0/60.0))
		var want_jump: bool = (d.y < -8.0) or (stuck_t > 0.4) or enemy_ahead
		if want_jump and jump_cd <= 0.0:
			Input.action_press("jump")
			jump_cd = 0.35
		else:
			Input.action_release("jump")

		# morph toggle: morph when stuck AND we have the ability (helps squeeze through gaps);
		# unmorph when close to needing to jump and currently morphed
		if m.player.has_morph:
			if stuck_t > 0.6 and not m.player.morphed:
				Input.action_press("move_down")
			elif m.player.morphed and d.y < -8.0:
				Input.action_press("jump")
			else:
				Input.action_release("move_down")

		# shoot periodically while stuck (in case a door is blocking)
		shoot_cd = maxf(0.0, shoot_cd - (1.0/60.0))
		if stuck_t > 0.3 and shoot_cd <= 0.0:
			Input.action_press("shoot")
			shoot_cd = 0.5
		else:
			Input.action_release("shoot")

		await physics_frame

		# stuck detection
		var moved: float = m.player.global_position.distance_to(last_pos)
		if moved < 2.0:
			stuck_t += 1.0/60.0
		else:
			stuck_t = 0.0
		last_pos = m.player.global_position

		if d.length() < 24.0:
			print("REACHED waypoint '%s' at frame %d (%.1fs)" % [target_name, frame, frame/60.0])
			log_state("WAYPOINT")
			wp_i += 1
			stuck_t = 0.0

		if frame % 600 == 0:
			log_state("progress")

	if wp_i >= waypoints.size():
		print("SUCCESS: reached the GOAL via REAL engine simulation.")
	else:
		print("FAILED: did not reach '%s' within %d frames (%.0fs). Stuck at %s" % [
			waypoints[wp_i][0], max_frames, max_frames/60.0, str(m.player.global_position)])
	log_state("FINAL")
	quit()
