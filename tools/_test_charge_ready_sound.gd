extends SceneTree
var m

# count only the READY-ding's own sound (distinguish it from the constantly retriggering
# "sonic_spin" charge-loop sound, which shares the "sfx" group and adds noise to a plain count)
func count_ready_dings() -> int:
	var c := 0
	for p in get_nodes_in_group("sfx"):
		if p.stream and String(p.stream.resource_path).contains("apear"):
			c += 1
	return c

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
	for i in range(5): await physics_frame

	Input.action_press("boomerang")
	var ding_seen_frame := -1
	var charge_t_at_ding := -1.0
	for i in range(130):   # ~2.17s, comfortably past CHARGE_TIME=1.8s
		await physics_frame
		if count_ready_dings() > 0 and ding_seen_frame == -1:
			ding_seen_frame = i
			charge_t_at_ding = m.player.charge_t
	print("ready-ding first seen at frame ", ding_seen_frame, " (expect ~108, i.e. 1.8s*60), charge_t=", charge_t_at_ding, " CHARGE_TIME=", m.player.CHARGE_TIME)

	# hold 20 more frames at full charge -- should NOT spawn a second ding (one-time trigger)
	for i in range(20): await physics_frame
	print("total ready-dings alive after holding longer: ", count_ready_dings(), " (expect 0 or 1, never a repeated retrigger)")
	Input.action_release("boomerang")
	print("DONE")
	quit()
