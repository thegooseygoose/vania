extends SceneTree
## Screenshot the new "W" water-walk power-up icon sitting in the level.
func _snap(name: String) -> void:
	for i in range(4): await RenderingServer.frame_post_draw
	var dir := "D:/best game/vania/_shots"
	DirAccess.make_dir_recursive_absolute(dir)
	get_root().get_texture().get_image().save_png("%s/%s.png" % [dir, name])
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player
	await _step(10)
	# drop the six existing icons in a row + the new W, next to Mario, so you see them together
	var shapes := ["boomerang", "waterwalk"]
	var bx: float = p.global_position.x + 26
	var by: float = p.global_position.y - 6
	for i in shapes.size():
		var pw = load("res://powerup.gd").new()
		pw.shape = shapes[i]
		pw.main = null                         # main=null → never auto-collected during the shot
		m.level.add_child(pw)
		pw.global_position = Vector2(bx + i * 26, by)
	await _step(6)
	await _snap("waterwalk_icon")
	print("SNAP waterwalk icon done")
	quit()
