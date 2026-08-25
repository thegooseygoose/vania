extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd"):
			print("  powerup shape=%s pos=%s gpos=%s collected=%s main=%s" % [c.shape, str(c.position), str(c.global_position), str(c.collected), str(c.main!=null)])
	print("grab_points:")
	for g in m.grab_points:
		print("  grab pos=%s gpos=%s" % [str(g.position), str(g.global_position)])
	# put player exactly on star
	var star=null
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd") and c.shape=="star": star=c
	p.global_position = star.global_position
	print("player set to %s; star gpos %s dist=%.1f" % [str(p.global_position), str(star.global_position), p.global_position.distance_to(star.global_position)])
	await _step(1)
	print("after 1 frame: player=%s star.collected=%s has_grapple=%s" % [str(p.global_position), str(star.collected), str(p.has_grapple)])
	quit()
