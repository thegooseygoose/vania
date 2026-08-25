extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	# rightmost terrain column
	var maxx=0
	for cell in m.terrain.get_used_cells(): maxx=max(maxx, cell.x)
	print("rightmost terrain col=%d (x=%d px)  FLAG_X=%d CASTLE_X=%d has_flag=%s" % [maxx, maxx*16, m.FLAG_X, m.CASTLE_X, str(m.has_flag)])
	# put player near the end and snap
	m.player.global_position = Vector2(maxx*16 - 100, 180)
	for i in range(10): await physics_frame
	for i in range(3): await RenderingServer.frame_post_draw
	get_root().get_texture().get_image().save_png("D:/best game/vania/_shots/vania_end.png")
	print("DONE"); quit()
