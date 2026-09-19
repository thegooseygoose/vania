extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	m.player.hp = 62   # partial health to see the segmented bar drain
	for i in range(3): await physics_frame

	var sv := SubViewport.new()
	sv.size = Vector2i(256, 240)
	sv.transparent_bg = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)
	# move the existing hud canvas into the subviewport so it renders with real state
	var canvas = m.hud._canvas
	canvas.get_parent().remove_child(canvas)
	sv.add_child(canvas)
	for i in range(5): await RenderingServer.frame_post_draw
	var img := sv.get_texture().get_image()
	if img:
		img.save_png("res://tools/_shot_hud.png")
		print("saved", img.get_size())
	else:
		print("no image")
	quit()
