extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var life = m.level.get_node_or_null("Life1")
	print("life=", life, " life.main=", life.main, " main.player=", m.player)
	print("tree paused=", paused)
	m.player.hp = 40.0
	m.player.global_position = life.global_position + Vector2(4, 0)
	for i in range(10):
		await physics_frame
		print("frame", i, "dist=", life.global_position.distance_to(m.player.global_position),
			"hp=", m.player.hp, "_active=", life._active)
	quit()
