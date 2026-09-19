extends SceneTree
## Boots Level30, finds the spawned LifeStation (from the painted tile), teleports the player
## onto it with low HP, and confirms: (1) it heals over time, (2) player.heal_lock engages while
## on it and releases when walking off.

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var life = null
	for n in m.level.get_children():
		if n is LifeStation:
			life = n
	if life == null:
		print("FAIL: no LifeStation spawned from the painted tile")
		quit(); return
	print("LifeStation spawned at %s" % str(life.global_position))

	m.player.hp = 30
	m.player.global_position = life.global_position + Vector2(2, 0)
	for i in range(90): await physics_frame   # 1.5s
	print("hp after 1.5s on tile: %s  heal_lock=%s" % [str(m.player.hp), str(m.player.heal_lock)])

	m.player.global_position = life.global_position + Vector2(200, 0)
	for i in range(10): await physics_frame
	print("heal_lock after stepping away: %s" % str(m.player.heal_lock))
	quit()
