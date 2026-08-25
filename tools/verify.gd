extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	print("START: player.big=%s  fire=%s  tier=%s" % [str(m.player.big), str(m.player.fire), m.player.tier()])
	# count power-up nodes in the level
	var pups := 0; var shapes := []
	for c in m.level.get_children():
		if c.get_script() == load("res://powerup.gd"):
			pups += 1; shapes.append(c.shape)
	print("power-ups in level: %d  shapes=%s" % [pups, str(shapes)])
	# snap a view of the start (power-ups sit above the ground near the start)
	m.player.global_position.x = 224   # walk the camera over to frame the power-ups
	for i in range(20): await physics_frame
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/vania_powerups.png")
	print("DONE")
	quit()
