extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player.global_position
	# UP shot
	var b=m.throw_boomerang(p+Vector2(0,-16), 1, true)
	var y0=b.global_position.y; var x0=b.global_position.x
	for i in range(8): await physics_frame
	if is_instance_valid(b):
		print("UP shot: aim=%s dy=%.1f dx=%.1f (expect dy<0, dx~0)"%[str(b.aim), b.global_position.y-y0, b.global_position.x-x0])
	else:
		print("UP shot despawned (traveled its range)")
	# SIDE shot still works
	var b2=m.throw_boomerang(p+Vector2(8,-4), 1, false)
	var sy=b2.global_position.y; var sx=b2.global_position.x
	for i in range(6): await physics_frame
	if is_instance_valid(b2):
		print("SIDE shot: aim=%s dx=%.1f dy=%.1f (expect dx>0, dy~0)"%[str(b2.aim), b2.global_position.x-sx, b2.global_position.y-sy])
	quit()
