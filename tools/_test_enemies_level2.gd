extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.debug_start_level = 14
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(60): await physics_frame
	print("player pos=", m.player.position, " on_floor=", m.player.is_on_floor(), " vy=", m.player.velocity.y)
	print("gords=", m.gords.size())
	print("enemies detail:")
	for e in m.enemies:
		print("  ", e.kind, " pos=", e.position)
	quit()
