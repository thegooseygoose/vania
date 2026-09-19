extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	print("door_pairs count=", m.door_pairs.size())
	# find the pair whose LEFT sits near x=96,y=201 (door2)
	var target_pair = null
	for pair in m.door_pairs:
		var L = pair[0]
		if is_instance_valid(L) and absf(L.global_position.x - 96*16) < 20 and absf(L.global_position.y - 201*16) < 20:
			target_pair = pair
			break
	if target_pair == null:
		print("COULD NOT FIND door2's pair in door_pairs!")
		quit(); return
	var L = target_pair[0]; var R = target_pair[1]
	print("door2 pair found: L pos=", L.global_position, " R pos=", R.global_position)
	# teleport player just left of L, facing right, close enough to shoot (within 48px)
	m.player.global_position = Vector2(L.global_position.x - 20, L.global_position.y)
	m.player.velocity = Vector2.ZERO
	m.player.facing = 1
	for i in range(10): await physics_frame
	# fire a shot
	Input.action_press("shoot")
	for i in range(3): await physics_frame
	Input.action_release("shoot")
	for i in range(20): await physics_frame
	print("after shot: L._shot=", L._shot, " R._shot=", R._shot, " L._body=", L._body)
	print("total door_parts=", m.door_parts.size())
	var near_door2 = []
	for dp in m.door_parts:
		if is_instance_valid(dp) and absf(dp.global_position.x - 1560) < 60 and absf(dp.global_position.y - 3208) < 20:
			near_door2.append([dp.global_position, dp.part, dp._shot])
	print("DoorParts near door2 location: ", near_door2)
	# now walk right through the doorway for a while
	Input.action_press("move_right")
	for i in range(180):
		await physics_frame
		if i % 5 == 0:
			var active_pair = m._door_walk_pair
			var active_desc = "none"
			if active_pair != null:
				active_desc = "L@%s R@%s dir=%d" % [str(active_pair[0].global_position), str(active_pair[1].global_position), m._door_walk_dir]
			print("t=%d pos=%s vel=%s door_walk=%d L._shot=%s R._shot=%s active_pair=[%s] hold=%.2f" % [
				i, str(m.player.global_position), str(m.player.velocity), m.player.door_walk, str(L._shot), str(R._shot), active_desc, m._door_cam_hold])
	Input.action_release("move_right")
	print("FINAL pos=", m.player.global_position)
	quit()
