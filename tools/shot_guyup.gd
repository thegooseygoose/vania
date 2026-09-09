extends SceneTree
var m
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/guyaim_%s.png"%n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13; Main.selected_char="guy"
	m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	print("guy has up frame: %s"%str(m.player._simple_tex.get("guy",{}).has("up")))
	for i in range(8): await physics_frame
	await _snap("stand")
	Input.action_press("move_up")
	for i in range(10): await physics_frame
	await _snap("up")
	Input.action_release("move_up")
	print("DONE")
	quit()
