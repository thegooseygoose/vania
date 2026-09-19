extends SceneTree
## Confirms the movement lock actually works: holding move_right while standing on the life tile
## should NOT build up velocity/move the player, but should work normally once off it.

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
	m.player.global_position = life.global_position + Vector2(2, 0)
	m.player.velocity.x = 0
	Input.action_press("move_right")
	for i in range(30): await physics_frame
	print("ON TILE holding right 0.5s: heal_lock=%s vx=%s moved_x=%s"
		% [str(m.player.heal_lock), str(m.player.velocity.x), str(m.player.global_position.x - (life.global_position.x + 2))])

	m.player.global_position = life.global_position + Vector2(300, 0)
	m.player.velocity.x = 0
	for i in range(30): await physics_frame
	print("OFF TILE holding right 0.5s: heal_lock=%s vx=%s" % [str(m.player.heal_lock), str(m.player.velocity.x)])
	Input.action_release("move_right")
	quit()
