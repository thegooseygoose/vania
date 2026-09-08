extends SceneTree
var main
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/door_%s.png"%n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	main=load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(50): await physics_frame
	main.start_delay=0.0; main.fade_alpha=0.0
	main.player.global_position=Vector2(34*16, 44*16); main.player.velocity=Vector2.ZERO
	for i in range(25): await physics_frame
	await _snap("near")
	print("DONE pos=(%.0f,%.0f)"%[main.player.global_position.x,main.player.global_position.y])
	quit()
