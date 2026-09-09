extends SceneTree
var intro
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/menu_%s.png"%n)
func _initialize(): call_deferred("_run")
func _run():
	intro=load("res://Intro.tscn").instantiate(); get_root().add_child(intro)
	for i in range(10): await process_frame
	intro.phase="mainmenu"; intro.mm_in_extras=false; intro.mm_sel=0; intro.t=0.2; intro.queue_redraw()
	for i in range(4): await process_frame
	await _snap("main")
	intro.mm_in_extras=true; intro.mm_sel=0; intro.queue_redraw()
	for i in range(4): await process_frame
	await _snap("extras")
	print("DONE")
	quit()
