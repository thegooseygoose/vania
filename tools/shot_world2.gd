extends SceneTree
var main
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/w2_%s.png"%n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	main=load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(50): await physics_frame
	main.start_delay=0.0; main.fade_alpha=0.0
	for i in range(20): await physics_frame
	await _snap("start")
	# also render whole terrain overview from the (edited) scene
	print("DONE doors_preserved_check enemies=%d"%main.enemies.size())
	quit()
