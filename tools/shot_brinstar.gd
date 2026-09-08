extends SceneTree
var main
func _snap(n): 
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/br_%s.png"%n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	main=load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(40): await physics_frame
	main.start_delay=0.0; main.fade_alpha=0.0
	for i in range(30): await physics_frame
	await _snap("top")
	main.player.global_position=Vector2(80, 340); main.player.velocity=Vector2.ZERO
	for i in range(60): await physics_frame
	await _snap("bottom")
	print("DONE")
	quit()
