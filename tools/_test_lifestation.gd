extends SceneTree
## Boots Brinstar (Level29) headlessly, drops the player's HP, teleports them next to the new
## Life1 station, ticks physics, and confirms HP rises back toward MAX_HP -- and stays put when
## the player is far away.

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13   # Brinstar play-slot
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var life = m.level.get_node_or_null("Life1")
	if life == null:
		print("FAIL: Life1 node not found in level")
		quit(); return
	print("Life1 found at %s" % str(life.global_position))

	m.player.hp = 40.0
	m.player.global_position = life.global_position + Vector2(4, 0)
	for i in range(120): await physics_frame   # 2s @60fps
	print("hp after 2s near station: %s (started 40, MAX %s)" % [str(m.player.hp), str(m.player.MAX_HP)])

	m.player.hp = 40.0
	m.player.global_position = life.global_position + Vector2(400, 0)
	for i in range(60): await physics_frame    # 1s
	print("hp after 1s far away: %s (should still be 40)" % str(m.player.hp))
	quit()
