extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	m.player.has_boomerang = true
	m.player.has_chargebeam = true
	m.player.global_position = Vector2(530 * 16, 400 * 16)
	m.player.velocity = Vector2.ZERO
	m.player.facing = 1
	for i in range(5): await physics_frame

	m.player.charge_t = 2.0   # simulate a fully-charged hold, then fire directly (bypasses synthetic
	                          # Input-action release-frame timing, which is what the earlier test's
	                          # boomerangs=0 result was likely an artifact of)
	m.player._fire_shot(m.player.charge_t >= m.player.CHARGE_TIME)
	print("direct fire: boomerangs=", m.player.boomerangs.size())
	if m.player.boomerangs.size() > 0:
		print("  power=", m.player.boomerangs[-1].power, " (expect 3, full charge)")
	print("DONE")
	quit()
