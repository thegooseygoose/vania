extends SceneTree
var main
func _snap(n):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("res://tools/_chargeflash_%s.png" % n)
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	main = load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(50): await physics_frame
	main.start_delay = 0.0; main.fade_alpha = 0.0
	main.player.has_boomerang = true
	main.player.has_chargebeam = true
	main.player.global_position = Vector2(60*16, 200*16)
	main.player.velocity = Vector2.ZERO
	main.player.facing = 1
	for i in range(5): await physics_frame

	Input.action_press("boomerang")
	for i in range(10): await physics_frame
	print("early charge: charge_t=", main.player.charge_t)
	await _snap("early")

	for i in range(35): await physics_frame   # ~0.75s total held
	print("mid charge: charge_t=", main.player.charge_t)
	await _snap("mid")

	for i in range(20): await physics_frame   # past CHARGE_TIME=0.9s
	print("full charge: charge_t=", main.player.charge_t, " CHARGE_TIME=", main.player.CHARGE_TIME)
	await _snap("full")

	Input.action_release("boomerang")
	for i in range(3): await physics_frame
	print("after release: charge_t=", main.player.charge_t, " boomerang active=", main.player.boomerang != null)
	await _snap("released")
	print("DONE")
	quit()
