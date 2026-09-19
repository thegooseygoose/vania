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

	Input.action_press("boomerang")
	for i in range(30): await physics_frame   # 0.5s held
	print("at 0.5s: charge_t=", m.player.charge_t, " CHARGE_TIME=", m.player.CHARGE_TIME,
		" sfx playing=", is_instance_valid(m.player._charge_beam_sfx) and m.player._charge_beam_sfx.playing)

	for i in range(60): await physics_frame   # +1.0s = 1.5s total
	print("at 1.5s: charge_t=", m.player.charge_t, " full=", m.player.charge_t >= m.player.CHARGE_TIME,
		" sfx playing=", is_instance_valid(m.player._charge_beam_sfx) and m.player._charge_beam_sfx.playing)

	for i in range(30): await physics_frame   # +0.5s = 2.0s total, should be full by 1.8s
	print("at 2.0s: charge_t=", m.player.charge_t, " full=", m.player.charge_t >= m.player.CHARGE_TIME,
		" sfx playing (expect false, stopped at full charge)=", is_instance_valid(m.player._charge_beam_sfx) and m.player._charge_beam_sfx.playing)

	Input.action_release("boomerang")
	await physics_frame
	print("1 frame after release: boomerangs=", m.player.boomerangs.size(), " charge_t=", m.player.charge_t)
	if m.player.boomerangs.size() > 0:
		print("  fired shot power=", m.player.boomerangs[-1].power, " (expect 3, full charge) pos=", m.player.boomerangs[-1].global_position)
	for i in range(2): await physics_frame
	print("3 frames after release: boomerangs=", m.player.boomerangs.size(), " sfx valid=", is_instance_valid(m.player._charge_beam_sfx))
	print("DONE")
	quit()
