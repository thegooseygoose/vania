extends SceneTree
var main
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	Main.selected_char = "hal2"
	main = load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(50): await physics_frame
	main.player.global_position = Vector2(60*16, 200*16)
	main.player.velocity = Vector2.ZERO
	main.player.facing = 1
	for i in range(10): await physics_frame
	print("facing right ok, no crash. facing_up=", main.player._facing_up())
	main.player.facing = -1
	for i in range(5): await physics_frame
	print("facing left ok, no crash.")
	Input.action_press("move_up")
	for i in range(10): await physics_frame
	print("aiming up: facing_up=", main.player._facing_up(), " (expect true)")
	Input.action_release("move_up")
	print("DONE, no crashes")
	quit()
