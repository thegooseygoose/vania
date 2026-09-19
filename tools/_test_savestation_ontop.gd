extends SceneTree
## Boots Level4, drops the player onto a SaveStation's solid block, lets them settle, then
## confirms: on_floor (standing on top physically), the "PRESS UP" prompt engages, and
## pressing UP actually saves while standing there.

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 4
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var save = null
	for n in m.level.get_children():
		if n is SaveStation:
			save = n
	m.player.global_position = save.global_position + Vector2(0, -60)
	m.player.velocity = Vector2.ZERO
	for i in range(90): await physics_frame

	print("settled: y=%s on_floor=%s near=%s" % [str(m.player.global_position.y), str(m.player.is_on_floor()), str(save._near)])

	Input.action_press("move_up")
	await physics_frame
	Input.action_release("move_up")
	for i in range(5): await physics_frame
	print("pressed UP while standing on top: checkpoint_active=%s" % str(m.checkpoint_active))
	quit()
