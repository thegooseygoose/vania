extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=2
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player
	# door test: give boomerang, stand before the door, throw through it at the switch
	p.has_boomerang=true
	var sw=m.door_switches[0]
	p.global_position=Vector2(94*16, 190); p.velocity=Vector2.ZERO; p.facing=1
	await _step(3)
	Input.action_press("boomerang"); await _step(2); Input.action_release("boomerang")
	for i in range(40): await physics_frame
	print("boomerang: switch triggered=%s  door tiles left=%d (want true, 0)" % [str(sw.triggered), m.door_tile_cells.size()])
	# goal test: touch the goal
	var gc=m.goal_cells[0]
	p.global_position=Vector2(gc.x*16+8, gc.y*16+8); p.velocity=Vector2.ZERO
	for i in range(4): await physics_frame
	print("goal touched -> game_state=%s (want clear)" % m.game_state)
	print("DONE"); quit()
