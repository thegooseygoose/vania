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
	# put the player in the TALON arena's tall open room (x520-575/y360-409, confirmed wide open)
	m.player.global_position = Vector2(530 * 16, 400 * 16)
	m.player.velocity = Vector2.ZERO
	m.player.facing = 1
	for i in range(5): await physics_frame

	# --- WITHOUT long beam: should stop at the old 48px cap ---
	m.player.has_longbeam = false
	var start_pos: Vector2 = m.player.global_position + Vector2(m.player.facing * 8, -4)
	m.player._fire_shot(false)
	var b = m.player.boomerang
	var max_dist_normal := 0.0
	for i in range(40):
		await physics_frame
		if is_instance_valid(b):
			max_dist_normal = maxf(max_dist_normal, b.global_position.distance_to(start_pos))
	print("WITHOUT long beam: max travel = ", max_dist_normal, " (expect ~48)")

	for i in range(10): await physics_frame

	# --- WITH long beam: should travel much farther (up to VIEW_W=256, or until off-screen/wall) ---
	m.player.has_longbeam = true
	start_pos = m.player.global_position + Vector2(m.player.facing * 8, -4)
	m.player._fire_shot(false)
	b = m.player.boomerang
	var max_dist_long := 0.0
	for i in range(80):
		await physics_frame
		if is_instance_valid(b):
			max_dist_long = maxf(max_dist_long, b.global_position.distance_to(start_pos))
	print("WITH long beam: max travel = ", max_dist_long, " (expect much > 48, up to ~", m.VIEW_W, ")")
	print("DONE")
	quit()
