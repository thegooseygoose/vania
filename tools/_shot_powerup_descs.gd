extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(20): await physics_frame

	var sv := SubViewport.new()
	sv.size = Vector2i(256, 240)
	sv.transparent_bg = false
	sv.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	get_root().add_child(sv)
	var canvas = m.hud._canvas
	canvas.get_parent().remove_child(canvas)
	sv.add_child(canvas)

	for shape in ["diamond", "star", "circle"]:
		m.collect_powerup(shape)
		m.powerup_phase = 1   # jump straight to the description card
		for i in range(3): await physics_frame
		for i in range(5): await RenderingServer.frame_post_draw
		var img := sv.get_texture().get_image()
		img.save_png("res://tools/_shot_desc_%s.png" % shape)
		print("saved ", shape, " -> ", img.get_size())
	quit()
