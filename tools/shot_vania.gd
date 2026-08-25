extends SceneTree
## Snap 1-1 running in the cloned Vania project (attract demo auto-plays it).
func _snap(name: String) -> void:
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/%s.png" % name)
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = true
	Main.save_slot = -1
	Main.debug_start_level = 1
	var main = load("res://Main.tscn").instantiate()
	get_root().add_child(main)
	for i in range(40): await physics_frame
	main.start_delay = 0.0
	main.fade_alpha = 0.0
	await _snap("vania_11_a")
	for i in range(240): await physics_frame   # ~4s of auto-play into the level
	await _snap("vania_11_b")
	print("player_x=%.0f dead=%s" % [main.player.global_position.x, str(main.player.dead)])
	print("DONE")
	quit()
