extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player
	p.has_morph = true
	p.global_position = Vector2(80, 190)
	for i in range(10): await physics_frame
	Input.action_press("move_down"); for i in range(2): await physics_frame; Input.action_release("move_down")
	for i in range(6): await physics_frame
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/vania_morph.png")
	print("morphed=%s" % str(p.morphed))
	quit()
