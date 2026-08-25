extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	# collect all
	for c in m.level.get_children():
		if c.get_script()==load("res://powerup.gd"):
			p.global_position=c.global_position; p.velocity=Vector2.ZERO
			await _step(3)
	print("FLAGS: djump=%s break=%s morph=%s wall=%s grapple=%s boom=%s" % [str(p.has_double_jump),str(p.has_break),str(p.has_morph),str(p.has_walljump),str(p.has_grapple),str(p.has_boomerang)])
	# grapple
	var gp=m.grab_points[0].global_position
	p.global_position=gp+Vector2(0,60); p.velocity=Vector2.ZERO
	await _step(2)
	Input.action_press("shoot"); await _step(2); Input.action_release("shoot")
	await _step(10)
	print("GRAPPLE: grappling=%s player_near_hang=%s" % [str(p.grappling), str(p.global_position.distance_to(gp)<30)])
	Input.action_press("jump"); await _step(2); Input.action_release("jump")
	print("  jump-off vy=%.0f grappling=%s" % [p.velocity.y, str(p.grappling)])
	# boomerang (away from grab point)
	p.grappling=false; p.global_position=Vector2(1000,190); p.velocity=Vector2.ZERO
	await _step(4)
	Input.action_press("shoot"); await _step(2); Input.action_release("shoot")
	var has_b = is_instance_valid(p.boomerang)
	print("BOOMERANG thrown=%s" % str(has_b))
	# flag/house gone?
	var flaghouse=0
	for cell in m.terrain.get_used_cells():
		if m.terrain.get_cell_atlas_coords(cell).x in [5,6,7]: flaghouse+=1
	print("flag/house tiles remaining=%d (want 0)" % flaghouse)
	print("DONE"); quit()
