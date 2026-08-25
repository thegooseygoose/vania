extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	m.start_delay = 0.0
	m.fade_alpha = 0.0
	# place the player partway up the staircase so the camera has scrolled up
	var p = m.player
	p.global_position = Vector2(m.lvl_bottom - 32 - 200, m.lvl_bottom - 32 - 200)  # ~200px up
	p.velocity = Vector2.ZERO
	for i in range(2): await physics_frame
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/vania_climb.png")
	print("cam_y=%.0f player_screen_y=%.0f" % [m.cam_y, p.global_position.y - m.cam_y])
	print("DONE")
	quit()
