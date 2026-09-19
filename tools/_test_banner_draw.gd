extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame

	m.collect_powerup("boostball")
	for i in range(5): await physics_frame   # phase 0 draw
	print("phase0 drawn ok, phase=", m.powerup_phase)

	m.powerup_elapsed = 6.0   # force past PHASE1_TIME
	for i in range(5): await physics_frame   # phase 1 draw
	print("phase1 drawn ok, phase=", m.powerup_phase)
	quit()
