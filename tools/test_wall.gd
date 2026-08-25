extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player; p.has_walljump=true
	# find a solid tile with empty to its LEFT and empty above (a wall face)
	var wall=null
	for cell in m.terrain.get_used_cells():
		var left=Vector2i(cell.x-1,cell.y); var up=Vector2i(cell.x,cell.y-1)
		if m.terrain.get_cell_source_id(left)<0 and m.terrain.get_cell_source_id(up)<0 and m.terrain.get_cell_source_id(Vector2i(cell.x-1,cell.y-1))<0:
			wall=cell; break
	# place Mario just LEFT of the wall face, airborne, NO input
	p.global_position=Vector2(wall.x*16 - 7, wall.y*16 - 4); p.velocity=Vector2(0,30)
	await _step(2)
	print("wall on right detected (no input held)? wall_dir=%d (want 1)" % p.wall_dir)
	# press jump -> wall jump
	Input.action_press("jump"); await _step(2)
	print("WALL JUMP: vy=%.0f (want ~-262 up)  vx=%.0f (want ~-215 = away/left)" % [p.velocity.y, p.velocity.x])
	Input.action_release("jump")
	# hold RIGHT (back into wall) — the shove should still carry left during wall_lock
	Input.action_press("move_right"); await _step(3)
	print("during lock, holding back-into-wall: vx=%.0f (should still be strongly left, not reversed)" % p.velocity.x)
	Input.action_release("move_right")
	print("DONE"); quit()
