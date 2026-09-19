extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame

	m.collect_powerup("chargebeam")
	print("right after: phase=", m.powerup_phase, " name=", m.powerup_name, " has_chargebeam=", m.player.has_chargebeam, " freeze_t=", m.powerup_freeze_t)

	# advance ~5.1 real seconds of physics (60fps)
	for i in range(int(5.1 * 60)):
		await physics_frame
	print("after ~5.1s: phase=", m.powerup_phase, " freeze_t=", m.powerup_freeze_t)

	# advance until freeze ends
	var guard := 0
	while m.powerup_freeze_t > 0.0 and guard < 1000:
		await physics_frame
		guard += 1
	print("after freeze ends: phase=", m.powerup_phase, " freeze_t=", m.powerup_freeze_t, " guard=", guard)

	# test boost ball flag + charge beam pickup for boostball too
	m.collect_powerup("boostball")
	print("boostball: has_boostball=", m.player.has_boostball, " name=", m.powerup_name)
	quit()
