extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 12   # LEVEL Z = play-slot 12
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(60)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	await _step(30)
	print("level_num=%d  file=%d  player=%s" % [m.level_num, m._level_file, "yes" if m.player else "no"])
	var used = m.terrain.get_used_rect()
	print("terrain used rect = ", used, " (floor tiles present = %s)" % (used.size.x > 0))
	# is the player standing on ground (not falling through)?
	await _step(60)
	print("player y=%.0f  on_floor=%s (should be resting on the floor, not falling)" % [m.player.global_position.y, m.player.is_on_floor()])
	print("DONE")
	quit()
