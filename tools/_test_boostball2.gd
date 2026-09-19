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
	# hold for WAY longer than BOOST_CHARGE_TIME (0.45s = ~27 frames) -- should NOT launch
	for i in range(90):
		await physics_frame
	print("after 90 frames held: boosting=%s boost_charge=%.2f velocity=%s" %
		[str(m.player.boosting), m.player.boost_charge, str(m.player.velocity)])

	Input.action_release("run")
	for i in range(5):
		await physics_frame
		print("  f=%d boosting=%s boost_charge=%.2f velocity=%s on_floor=%s" %
			[i, str(m.player.boosting), m.player.boost_charge, str(m.player.velocity), str(m.player.is_on_floor())])
	quit()
