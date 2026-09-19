extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var turret = null
	for e in m.enemies:
		if e.kind == "turret": turret = e
	if turret == null:
		print("FAIL: no turret found")
		quit(); return
	print("turret found at ", turret.global_position, " TURRET_FIRE=", turret.TURRET_FIRE)
	# put the player near it and on-screen so it actually fires
	m.player.global_position = turret.global_position + Vector2(0, 60)
	for i in range(10): await physics_frame

	# watch turret.fire_timer resets (it zeroes exactly when it fires)
	var last_timer = turret.fire_timer
	var fire_times := []
	var t := 0.0
	for i in range(240):   # 4 seconds at 60fps
		await physics_frame
		t += 1.0 / 60.0
		if turret.fire_timer < last_timer - 0.01:   # timer just reset -> it fired
			fire_times.append(t)
		last_timer = turret.fire_timer
	print("fire times over 4s: ", fire_times)
	if fire_times.size() >= 2:
		var gaps := []
		for i in range(1, fire_times.size()):
			gaps.append(fire_times[i] - fire_times[i-1])
		print("gaps between shots: ", gaps, " (expect ~1.0s each now, was ~0.5s)")
	quit()
