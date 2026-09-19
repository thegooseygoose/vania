extends SceneTree
var main
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("res://tools/_hal2_gun_%s.png" % n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	Main.selected_char = "hal2"
	main = load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(50): await physics_frame
	main.start_delay = 0.0; main.fade_alpha = 0.0
	main.player.global_position = Vector2(60*16, 200*16)
	main.player.velocity = Vector2.ZERO
	main.player.facing = 1
	for i in range(10): await physics_frame
	await _snap("right")
	main.player.facing = -1
	for i in range(5): await physics_frame
	await _snap("left")
	Input.action_press("move_up")
	for i in range(10): await physics_frame
	await _snap("up")
	Input.action_release("move_up")
	print("DONE")
	quit()
