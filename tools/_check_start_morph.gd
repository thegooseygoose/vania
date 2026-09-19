extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	print("saved_abilities=", m.saved_abilities)
	print("player.has_morph=", m.player.has_morph, " player.morphed=", m.player.morphed)
	print("has_boomerang=", m.player.has_boomerang, " has_grapple=", m.player.has_grapple)
	quit()
