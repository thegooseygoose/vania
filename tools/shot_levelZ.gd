extends SceneTree
## Boots Level Z and snaps the viewport at several spots so the layout can be eyeballed.
## Run (needs a render context, NOT --headless): Godot --path . -s tools/shot_levelZ.gd

var main

func _snap(nm: String) -> void:
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/lz_%s.png" % nm)

func _initialize(): call_deferred("_run")

func _run() -> void:
	Main.attract_mode = false
	Main.save_slot = -1
	Main.debug_start_level = 28
	main = load("res://Main.tscn").instantiate()
	get_root().add_child(main)
	for i in range(40): await physics_frame
	main.start_delay = 0.0
	main.fade_alpha = 0.0
	# freeze so the player doesn't fall/move while we pan
	var spots := {
		"r1_start": Vector2(80, 208),
		"r1_mid":   Vector2(520, 208),
		"r2":       Vector2(1140, 208),
		"r3_floor": Vector2(1600, 208),
		"r3_shaft": Vector2(2240, -300),
		"r4":       Vector2(2300, 208),
	}
	for nm in spots:
		main.player.global_position = spots[nm]
		main.player.velocity = Vector2.ZERO
		# snap the camera straight to this spot so the slow room-scroll doesn't lag the shot
		main._cam_seg = []
		main._cam_lock = false
		for i in range(150): await physics_frame
		await _snap(nm)
		print("snapped ", nm, " cam=(%.0f,%.0f) px=(%.0f,%.0f)" % [main.cam_x, main.cam_y, main.player.global_position.x, main.player.global_position.y])
	print("DONE")
	quit()
