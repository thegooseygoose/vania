extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _snap(nm):
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/%s.png" % nm)
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=2
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	for spot in [[24,"l2_djump"],[50,"l2_wall"],[62,"l2_morph"],[81,"l2_grapple"],[99,"l2_door"]]:
		p.global_position=Vector2(spot[0]*16+8, 190); p.velocity=Vector2.ZERO
		for i in range(8): await physics_frame
		await _snap(spot[1])
	print("DONE"); quit()
