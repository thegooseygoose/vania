extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay=0.0; m.fade_alpha=0.0
	var p = m.player
	var bike=null
	for c in m.level.get_children():
		if c.get_script()==load("res://bike.gd"): bike=c

	# ground row 12, water rows 9..11 on top (shallow pool with footing)
	for c in range(120, 150):
		m.terrain.set_cell(Vector2i(c,12),0,Vector2i(m.ATLAS_GROUND,0))
		for r in [9,10,11]:
			m.terrain.set_cell(Vector2i(c,r),0,Vector2i(m.ATLAS_WATER if r>9 else m.ATLAS_WATER_TOP,0))
	m._collect_water()

	# --- TINT while submerged ---
	p.global_position = Vector2(130*16+8, 12*16 - p.col_size.y*0.5)   # standing, torso in water
	await _step(6)
	print("TINT: submerged=%s modulate=%s (want bluish ~0.55,0.75,1)" % [str(p.submerged), str(p.sprite.modulate)])

	# --- NO DOUBLE JUMP OUT OF WATER ---
	p.has_double_jump = true
	p.global_position = Vector2(130*16+8, 12*16 - p.col_size.y*0.5); p.velocity=Vector2.ZERO
	await _step(6)
	Input.action_press("jump"); await _step(2); Input.action_release("jump")   # jump out of water
	# rise until out of the water (submerged false)
	for i in range(30):
		await physics_frame
		if not p.submerged and p.velocity.y < 0: break
	var vy_pre = p.velocity.y
	Input.action_press("jump"); await _step(1)                                   # try double jump
	var vy_post = p.velocity.y
	Input.action_release("jump")
	print("DBL-JUMP OUT OF WATER: submerged=%s air_was_submerged=%s air_jump_used=%s vy %.0f->%.0f (should NOT jump)" % [
		str(p.submerged), str(p.air_was_submerged), str(p.air_jump_used), vy_pre, vy_post])

	# --- BIKE SPEED (~0.36*77=27.7) ---
	bike.ridden=true; p.riding=true; p.bike=bike; bike.armed=true
	for c in range(300, 340): m.terrain.set_cell(Vector2i(c,12),0,Vector2i(m.ATLAS_GROUND,0))
	p.global_position=Vector2(305*16+8, 12*16 - p.col_size.y*0.5); p.velocity=Vector2.ZERO
	await _step(4)
	Input.action_press("move_right")
	var pk:=0.0
	for i in range(60): await physics_frame; pk=maxf(pk,absf(p.velocity.x))
	Input.action_release("move_right")
	print("BIKE speed=%.1f (want ~28)" % pk)

	# --- DISMOUNT jump+down, no instant re-mount ---
	p.global_position = bike.global_position + Vector2(0, -p.col_size.y*0.5)
	await _step(2)
	Input.action_press("move_down"); Input.action_press("jump"); await _step(2)
	Input.action_release("jump")
	print("DISMOUNT: riding=%s armed=%s (want riding=false, armed=false)" % [str(p.riding), str(bike.armed)])
	# stay near the bike a moment: should NOT re-mount (disarmed)
	Input.action_release("move_down")
	p.global_position = bike.global_position + Vector2(0,-p.col_size.y*0.5)
	await _step(6)
	print("NEAR bike still: riding=%s (want false — no re-mount while disarmed)" % str(p.riding))
	# walk away, then back -> re-mounts
	p.global_position = bike.global_position + Vector2(200,0); await _step(3)
	p.global_position = bike.global_position + Vector2(0,-p.col_size.y*0.5); await _step(3)
	print("AWAY then BACK: riding=%s (want true — re-armed)" % str(p.riding))

	print("DONE")
	quit()
