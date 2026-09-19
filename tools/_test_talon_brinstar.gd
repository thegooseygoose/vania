extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13   # Brinstar play-slot
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	print("level_file=", m._level_file, " enemies=", m.enemies.size())
	var talon = null
	for e in m.enemies:
		if e.kind == "talon": talon = e
	if talon == null:
		print("FAIL: no talon enemy found in Brinstar")
	else:
		print("talon found in Brinstar: pos=", talon.global_position, " hp=", talon.talon_hp,
			" state=", talon.talon_state, " active=", talon.active)
	quit()
