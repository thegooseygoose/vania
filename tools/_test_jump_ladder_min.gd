extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	m.player.global_position = Vector2(167 * 16 + 8, 190 * 16 + 8)
	m.player.velocity = Vector2.ZERO
	for i in range(20): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor(), " floor_snap_length=", m.player.floor_snap_length, " col_size=", m.player.col_size, " selected_char=", Main.selected_char)
	m.player.jump_held = false
	m.player.floor_snap_length = 0.0
	Input.action_press("jump")
	for f in range(1, 11):
		await physics_frame
		print("f=%d pos=%s vel=%s on_floor=%s" % [f, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
	Input.action_release("jump")
	quit()
