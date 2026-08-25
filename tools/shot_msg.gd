extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	m.hud.show_message("GROUND POUND!  (jump, then Down)", 5.0)
	var w = float(m.hud.font.text_w("GROUND POUND!  (jump, then Down)", 1.0))
	print("msg width @1.0 = %.0f px (screen=256)" % w)
	for i in range(4): await physics_frame
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/vania_msg.png")
	quit()
