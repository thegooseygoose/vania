extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame

	m.player.has_morph = true
	m.player.has_boostball = true
	m.player.velocity = Vector2.ZERO
	for i in range(10): await physics_frame
	m.player.morphed = true
	m.player.facing = 1
	for i in range(5): await physics_frame

	Input.action_press("run")
	for i in range(15):
		await physics_frame
		if i % 5 == 0:
			var sfx_playing = m.player._boost_charge_sfx != null and is_instance_valid(m.player._boost_charge_sfx) and m.player._boost_charge_sfx.playing
			print("f=%d charge=%.2f sfx_playing=%s" % [i, m.player.boost_charge, str(sfx_playing)])

	# now hold PAST full charge (should be silent, "ready")
	for i in range(20):
		await physics_frame
	var sfx_ready = m.player._boost_charge_sfx != null and is_instance_valid(m.player._boost_charge_sfx) and m.player._boost_charge_sfx.playing
	print("fully charged (ready): charge=%.2f sfx_playing=%s" % [m.player.boost_charge, str(sfx_ready)])

	Input.action_release("run")
	for i in range(3): await physics_frame
	print("after release: boosting=%s" % str(m.player.boosting))
	quit()
