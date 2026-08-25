extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	# LEVEL EDITS: report powerup + grab point positions (tile coords)
	print("--- your level layout ---")
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd"):
			print("  powerup %-9s at tile (%d,%d)" % [c.shape, int(c.position.x/16), int(c.position.y/16)])
	for g in m.grab_points:
		print("  GRAB POINT at tile (%d,%d)" % [int(g.position.x/16), int(g.position.y/16)])
	# GRAPPLE fling distance using the real grab point
	p.has_grapple=true
	var a=m.grab_points[0].global_position if m.grab_points.size()>0 else Vector2(400,150)
	p.global_position=a+Vector2(45,10); p.velocity=Vector2.ZERO; await _step(2)
	Input.action_press("grapple"); await _step(2)
	Input.action_press("move_left"); await _step(14)
	Input.action_release("grapple")   # release Y -> launch
	await _step(1)
	var x0=p.global_position.x
	for i in range(60): await physics_frame
	Input.action_release("move_left")
	print("GRAPPLE fling ~= %.1f tiles (target ~6-9 for a gap)" % ((x0-p.global_position.x)/16.0))
	# BOOMERANG distance
	p.has_boomerang=true; p.global_position=Vector2(a.x, a.y+120); p.velocity=Vector2.ZERO; p.facing=1
	await _step(4)
	Input.action_press("boomerang"); await _step(2); Input.action_release("boomerang")
	var bx0=p.global_position.x; var maxout=0.0
	for i in range(60):
		await physics_frame
		if is_instance_valid(p.boomerang): maxout=max(maxout, p.boomerang.global_position.x - bx0)
	print("BOOMERANG max reach = %.0f px (%.1f tiles)  [was ~67px/4.2t]" % [maxout, maxout/16.0])
	print("DONE"); quit()
