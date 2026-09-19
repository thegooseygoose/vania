extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	m.player.has_boomerang = true
	m.player.global_position = Vector2(530 * 16, 400 * 16)
	m.player.velocity = Vector2.ZERO
	m.player.facing = 1
	for i in range(20): await physics_frame   # extra settle time

	m.player.has_longbeam = false
	var start_pos: Vector2 = m.player.global_position + Vector2(m.player.facing * 8, -4)
	m.player._fire_shot(false)
	var b = m.player.boomerang
	print("frame0: boomerang valid=", is_instance_valid(b), " pos=", (b.global_position if is_instance_valid(b) else "n/a"))
	var max_dist := 0.0
	for i in range(40):
		await physics_frame
		if is_instance_valid(b):
			var d: float = b.global_position.distance_to(start_pos)
			max_dist = maxf(max_dist, d)
			if i < 5: print("frame", i+1, ": pos=", b.global_position, " dist=", d)
		else:
			print("frame", i+1, ": boomerang freed")
			break
	print("WITHOUT long beam final max travel = ", max_dist)
	quit()
