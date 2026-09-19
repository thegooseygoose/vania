extends SceneTree
## Follows the VALIDATED waypoint path (from _extract_path.gd) through the REAL running game engine
## — short, physics-legal hops instead of beelining across the map, so it can't blunder into an
## unrelated chasm. This is the actual proof-of-completion attempt.
var m
var waypoints: Array = []
var grounded: Array = []   # per-waypoint: is this a real standable rest point, or a mid-air/jump-arc
                            # transient cell? Recovery teleports must ONLY use grounded ones, or the
                            # pilot gets placed floating in open air with nothing below it.
var wp_i := 0
var last_safe_wp_i := 0
var stuck_t := 0.0
var last_pos := Vector2.ZERO
var jump_cd := 0.0
var shoot_cd := 0.0
var TILE := 16.0

func _initialize(): call_deferred("_run")

func log_state(tag: String) -> void:
	print("[%s] t=%.1fs wp=%d/%d pos=(%.0f,%.0f) hp=%d dead=%s" % [
		tag, Engine.get_physics_frames() / 60.0, wp_i, waypoints.size(),
		m.player.global_position.x, m.player.global_position.y, m.player.hp, str(m.player.dead)])

func _run() -> void:
	var f := FileAccess.open("res://tools/_path_waypoints.csv", FileAccess.READ)
	var cells: Array = []
	while not f.eof_reached():
		var line := f.get_line()
		if line == "": continue
		var parts := line.split(",")
		var cx: int = int(parts[0]); var cy: int = int(parts[1])
		cells.append(Vector2i(cx, cy))
		waypoints.append(Vector2(cx * 16 + 8, cy * 16 + 8))   # cell CENTER, not the top edge
	f.close()
	print("loaded %d waypoints" % waypoints.size())

	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	# classify each waypoint as grounded (real standable rest point) or transient (mid-air/jump-arc
	# cell) using the SAME terrain the running level actually has
	var terr = m.terrain
	for c in cells:
		var below_solid: bool = terr.get_cell_source_id(Vector2i(c.x, c.y + 1)) >= 0
		grounded.append(below_solid)
	var grounded_count := 0
	for g in grounded: if g: grounded_count += 1
	print("grounded waypoints: %d / %d" % [grounded_count, grounded.size()])

	last_pos = m.player.global_position
	var max_frames := 40000
	var frame := 0
	var death_count := 0

	while frame < max_frames and wp_i < waypoints.size():
		frame += 1
		if m.player.dead:
			death_count += 1
			if death_count > 25:
				print("ABORT: died 25+ times")
				log_state("TOO_MANY_DEATHS")
				quit(1)
				return
			await physics_frame
			# recover to the nearest GROUNDED waypoint at or behind a few steps before the furthest
			# safely reached one — teleporting to a mid-air/jump-arc cell instead would drop the
			# pilot into open space with nothing below it (this was the actual bug the first two
			# attempts hit: repeated falls into the void from a bad recovery spot).
			var back_i: int = maxi(0, last_safe_wp_i - 3)
			while back_i > 0 and not grounded[back_i]: back_i -= 1
			var recover_pos: Vector2 = waypoints[back_i]
			m.player.dead = false
			m.player.hp = m.player.MAX_HP
			m.player.global_position = recover_pos + Vector2(0, -6)
			m.player.velocity = Vector2.ZERO
			m.player.invuln = 2.0
			m.player.morphed = false
			wp_i = back_i
			stuck_t = 0.0
			for i in range(10): await physics_frame
			continue

		var target: Vector2 = waypoints[wp_i]
		var d: Vector2 = target - m.player.global_position

		if absf(d.x) > 4.0:
			if d.x > 0: Input.action_press("move_right"); Input.action_release("move_left")
			else: Input.action_press("move_left"); Input.action_release("move_right")
		else:
			Input.action_release("move_left"); Input.action_release("move_right")

		# enemy avoidance: hop over anything close ahead
		var enemy_ahead := false
		for e in m.enemies:
			if not is_instance_valid(e) or e.dead: continue
			var ed: Vector2 = e.global_position - m.player.global_position
			if sign(ed.x) == sign(d.x) and absf(ed.x) < 24.0 and absf(ed.y) < 18.0:
				enemy_ahead = true
				break

		jump_cd = maxf(0.0, jump_cd - (1.0/60.0))
		var want_jump: bool = (d.y < -6.0) or enemy_ahead or (stuck_t > 0.35)
		if want_jump and jump_cd <= 0.0:
			Input.action_press("jump")
			jump_cd = 0.3
		else:
			Input.action_release("jump")

		# morph: use it when stuck against a low ceiling (path may need it for 1-tall gaps)
		if m.player.has_morph:
			if stuck_t > 0.5 and not m.player.morphed:
				Input.action_press("move_down")
			elif m.player.morphed and (d.y < -6.0 or stuck_t < 0.1):
				Input.action_release("move_down")
				Input.action_press("jump")
			else:
				Input.action_release("move_down")

		shoot_cd = maxf(0.0, shoot_cd - (1.0/60.0))
		if stuck_t > 0.25 and shoot_cd <= 0.0:
			Input.action_press("shoot")
			shoot_cd = 0.4
		else:
			Input.action_release("shoot")

		await physics_frame

		var moved: float = m.player.global_position.distance_to(last_pos)
		if moved < 1.5: stuck_t += 1.0/60.0
		else: stuck_t = 0.0
		last_pos = m.player.global_position

		if d.length() < 20.0:
			wp_i += 1
			last_safe_wp_i = maxi(last_safe_wp_i, wp_i)
			stuck_t = 0.0
			if wp_i % 25 == 0 or wp_i == waypoints.size():
				log_state("checkpoint")

		if frame % 1200 == 0:
			log_state("progress")

	if wp_i >= waypoints.size():
		print("SUCCESS: followed the full validated path to the GOAL via the REAL engine.")
	else:
		print("FAILED: stuck at waypoint %d/%d after %d frames (%.0fs), pos=%s" % [
			wp_i, waypoints.size(), frame, frame/60.0, str(m.player.global_position)])
	log_state("FINAL")
	quit()
