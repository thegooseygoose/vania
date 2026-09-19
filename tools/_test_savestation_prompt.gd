extends SceneTree
## Boots Level7 (has Save1/Save2), confirms: no auto-save just from proximity, the "PRESS UP TO
## SAVE" prompt (_near) engages in range, and pressing move_up actually saves.

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 4   # 1-4: has 3 real save stations
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var save = null
	for n in m.level.get_children():
		if n is SaveStation:
			save = n
	if save == null:
		print("FAIL: no SaveStation found")
		quit(); return
	print("SaveStation at %s" % str(save.global_position))

	m.player.global_position = save.global_position + Vector2(4, 0)
	for i in range(20): await physics_frame
	print("standing near, no button: near=%s checkpoint_active=%s" % [str(save._near), str(m.checkpoint_active)])

	Input.action_press("move_up")
	await physics_frame
	Input.action_release("move_up")
	for i in range(5): await physics_frame
	print("after pressing UP: checkpoint_active=%s checkpoint_pos=%s" % [str(m.checkpoint_active), str(m.checkpoint_pos)])

	m.player.global_position = save.global_position + Vector2(300, 0)
	for i in range(10): await physics_frame
	print("walked away: near=%s" % str(save._near))
	quit()
