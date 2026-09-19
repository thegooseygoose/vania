extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	print("level_file=", m._level_file, " player pos=", m.player.global_position, " enemies=", m.enemies.size())
	print("abilities: double_jump=", m.player.has_double_jump, " morph=", m.player.has_morph,
		" boostball=", m.player.has_boostball, " chargebeam=", m.player.has_chargebeam)
	quit()
