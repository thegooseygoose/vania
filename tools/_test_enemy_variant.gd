extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	for v in [1, 2]:
		Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14; Main.enemy_variant = v
		m = load("res://Main.tscn").instantiate()
		get_root().add_child(m)
		for i in range(30): await physics_frame
		var scripts := {}
		for e in m.enemies:
			var sp: String = e.get_script().resource_path.get_file()
			scripts[sp] = int(scripts.get(sp, 0)) + 1
		print("variant %d -> enemy scripts: %s" % [v, str(scripts)])
		m.queue_free()
		await physics_frame
	quit()
