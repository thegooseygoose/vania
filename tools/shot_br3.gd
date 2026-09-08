extends SceneTree
var main
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/br3_%s.png"%n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	main=load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(50): await physics_frame
	main.start_delay=0.0; main.fade_alpha=0.0
	main.player.global_position=Vector2(16*16+8, 19*16); main.player.velocity=Vector2.ZERO
	for i in range(20): await physics_frame
	await _snap("morph")
	main.player.global_position=Vector2(38*16+8, 19*16); main.player.velocity=Vector2.ZERO
	for i in range(20): await physics_frame
	await _snap("goal")
	print("DONE")
	quit()
