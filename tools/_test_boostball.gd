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
	print("pre-morph on_floor=", m.player.is_on_floor(), " pos=", m.player.global_position)
	m.player.morphed = true
	for i in range(5): await physics_frame
	print("post-morph on_floor=", m.player.is_on_floor())

	m.player.facing = 1
	Input.action_press("run")
	var triggered_frame := -1
	for i in range(60):
		await physics_frame
		if m.player.boosting and triggered_frame == -1:
			triggered_frame = i
			print("boost triggered at frame %d, velocity=%s" % [i, str(m.player.velocity)])
	Input.action_release("run")
	print("boosting still true after loop=", m.player.boosting, " triggered=", triggered_frame != -1)
	quit()
