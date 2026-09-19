extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	m.player.has_boomerang = true
	m.player.has_chargebeam = false
	m.player.global_position = Vector2(530 * 16, 400 * 16)   # TALON arena, wide open
	m.player.velocity = Vector2.ZERO
	m.player.facing = 1
	for i in range(20): await physics_frame

	# fire 1st shot
	m.player._fire_shot(false)
	print("after shot1: active=", m.player.boomerangs.size(), " (expect 1)")

	# try firing a 2nd immediately (should be ALLOWED now -- doubled fire rate)
	m.player.boomerangs = m.player.boomerangs.filter(func(b): return is_instance_valid(b))
	var can_fire_2: bool = m.player.has_boomerang and not m.player.morphed and m.player.boomerangs.size() < m.player.MAX_ACTIVE_SHOTS
	print("can fire 2nd shot right after 1st: ", can_fire_2, " (expect true)")
	if can_fire_2:
		m.player._fire_shot(false)
	print("after shot2: active=", m.player.boomerangs.size(), " (expect 2)")

	# a 3rd should be BLOCKED until one of the first two clears
	m.player.boomerangs = m.player.boomerangs.filter(func(b): return is_instance_valid(b))
	var can_fire_3: bool = m.player.has_boomerang and not m.player.morphed and m.player.boomerangs.size() < m.player.MAX_ACTIVE_SHOTS
	print("can fire 3rd shot with 2 already active: ", can_fire_3, " (expect false)")

	# wait for both to clear naturally, then confirm firing opens back up
	for i in range(60):
		await physics_frame
	m.player.boomerangs = m.player.boomerangs.filter(func(b): return is_instance_valid(b))
	print("after waiting: active=", m.player.boomerangs.size(), " (expect 0, both despawned)")
	print("DONE")
	quit()
