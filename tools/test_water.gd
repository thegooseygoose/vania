extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _paint(m, c0: int, c1: int, r0: int, r1: int) -> void:
	for c in range(c0, c1 + 1):
		for r in range(r0, r1 + 1):
			m.terrain.set_cell(Vector2i(c, r), 0, Vector2i(m.ATLAS_WATER, 0))
	m._collect_water()

func _clear(m) -> void:
	for cell in m.terrain.get_used_cells():
		var ax: int = m.terrain.get_cell_atlas_coords(cell).x
		if ax == m.ATLAS_WATER or ax == m.ATLAS_WATER_TOP:
			m.terrain.erase_cell(cell)
	m._collect_water()

# hold right+run in a WIDE open-air pool; return peak horizontal speed
func _top_speed(m, p, wet: bool) -> float:
	_clear(m)
	if wet:
		_paint(m, 380, 460, -40, 20)          # wide + tall pool so he stays submerged
	p.global_position = Vector2(400*16+8, -20*16); p.velocity = Vector2.ZERO
	await _step(2)
	Input.action_press("run"); Input.action_press("move_right")
	var peak := 0.0
	for i in range(70):
		await physics_frame
		peak = maxf(peak, absf(p.velocity.x))
	Input.action_release("run"); Input.action_release("move_right")
	return peak

func _run() -> void:
	Main.save_slot = -1
	Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player

	var src = m.terrain.tile_set.get_source(0)
	print("tileset water registered: 45=%s 46=%s" % [
		str(src.has_tile(Vector2i(m.ATLAS_WATER_TOP, 0))), str(src.has_tile(Vector2i(m.ATLAS_WATER, 0)))])

	_paint(m, 20, 24, 5, 9)
	print("in_water inside=%s outside=%s" % [
		str(m.in_water(Vector2(22*16, 7*16))), str(m.in_water(Vector2(22*16, 40*16)))])
	_clear(m)

	var dry = await _top_speed(m, p, false)
	var wet = await _top_speed(m, p, true)
	print("RUN top speed  dry=%.1f  wet=%.1f  ratio=%.2f (expect ~0.50)" % [dry, wet, wet/maxf(dry,0.01)])

	# ---- jump launch: build a solid platform sitting inside a water pool ----
	# dry jump (open air with the game's own ground at x=80)
	_clear(m)
	p.global_position = Vector2(80, 150); p.velocity = Vector2.ZERO
	await _step(50)
	Input.action_press("jump"); await _step(1)
	var vj_dry = p.velocity.y
	Input.action_release("jump"); await _step(25)
	# wet jump: an isolated solid floor tile at (col 500,row 20) with water filling the rows above
	var fc := 500
	for c in range(fc-2, fc+3):
		m.terrain.set_cell(Vector2i(c, 20), 0, Vector2i(m.ATLAS_GROUND, 0))   # solid platform
	m._collect_water()   # no water yet — dry platform baseline
	p.global_position = Vector2(fc*16+8, 19*16); p.velocity = Vector2.ZERO
	await _step(40)
	Input.action_press("jump"); await _step(1)
	print("   [probe] DRY-platform jump vy=%.1f on_floor_pre=irrelevant" % p.velocity.y)
	Input.action_release("jump"); await _step(25)
	_paint(m, fc-2, fc+2, 12, 19)                                            # now flood it
	p.global_position = Vector2(fc*16+8, 19*16); p.velocity = Vector2.ZERO
	await _step(40)
	var sub = p.submerged; var of_pre = p.is_on_floor()
	print("   [probe] pre-wet-jump: jump_held=%s ducking=%s morphed=%s slamming=%s duck_locked=%s" % [
		str(p.jump_held), str(p.ducking), str(p.morphed), str(p.slamming), str(p.duck_locked)])
	Input.action_press("jump"); await _step(1)
	var vj_wet = p.velocity.y
	Input.action_release("jump")
	print("JUMP vy  dry=%.1f  wet=%.1f(submerged=%s floor_pre=%s) ratio=%.2f (expect ~0.72)" % [
		vj_dry, vj_wet, str(sub), str(of_pre), vj_wet/minf(vj_dry,-0.01)])

	# ---- SINGLE JUMP: double-jump must NOT work in water ----
	p.has_double_jump = true
	p.global_position = Vector2(fc*16+8, 19*16); p.velocity = Vector2.ZERO
	await _step(30)
	Input.action_press("jump"); await _step(2); Input.action_release("jump")   # 1st (ground) jump
	await _step(6)                                                            # now airborne, rising/apex
	var vy_before2 = p.velocity.y
	Input.action_press("jump"); await _step(1)                               # try a 2nd jump in mid-air
	var vy_after2 = p.velocity.y
	Input.action_release("jump")
	print("DOUBLE-JUMP in water: vy before=%.1f after=%.1f air_jump_used=%s (should NOT jump: after ~>= before)" % [
		vy_before2, vy_after2, str(p.air_jump_used)])

	# ---- NO HOVER: holding jump underwater should still sink (no floaty hold) ----
	p.has_double_jump = false
	p.global_position = Vector2(fc*16+8, 14*16); p.velocity = Vector2.ZERO   # start mid-water, no footing
	Input.action_press("jump")
	await _step(30)
	Input.action_release("jump")
	print("HOLD-JUMP hover check: vy=%.1f (should be sinking ~+90, not hovering near 0)" % p.velocity.y)

	# ---- RUN ONTO WATER: moving fast across a pool over OPEN AIR must SINK, not skate ----
	_clear(m)
	# a solid runway at row 10, then a wide water pool (no ground beneath) from col 210 on
	for c in range(200, 210):
		m.terrain.set_cell(Vector2i(c, 10), 0, Vector2i(m.ATLAS_GROUND, 0))
	_paint(m, 210, 240, 4, 9)            # deep water column over open space (rows 4..9, nothing below)
	m._collect_water()
	p.global_position = Vector2(208*16, 9*16); p.velocity = Vector2(200, 0)   # sprinting right at the pool
	Input.action_press("run"); Input.action_press("move_right")
	var surface_y = p.global_position.y
	await _step(30)
	Input.action_release("run"); Input.action_release("move_right")
	var sank = p.global_position.y - surface_y
	print("RUN-ONTO-WATER: sank %.0f px, on_floor=%s submerged=%s (should sink a lot, not stay ~0)" % [
		sank, str(p.is_on_floor()), str(p.submerged)])

	# ---- WATER-WALK power: as if the water isn't there (normal speed/fall in water) ----
	p.has_waterwalk = true
	_clear(m)
	_paint(m, 250, 290, -6, 20)                 # tall deep pool over open air
	p.global_position = Vector2(270*16+8, -2*16); p.velocity = Vector2.ZERO
	Input.action_press("run"); Input.action_press("move_right")
	var pk := 0.0
	for i in range(35):
		await physics_frame
		pk = maxf(pk, absf(p.velocity.x))
	Input.action_release("run"); Input.action_release("move_right")
	print("WATER-WALK: in-water fall vy=%.1f (expect >150, NORMAL not the 90 sink)  top speed=%.1f (expect ~76)  submerged=%s" % [
		p.velocity.y, pk, str(p.submerged)])
	p.has_waterwalk = false

	# ---- fall terminal velocity while submerged ----
	_clear(m)
	_paint(m, 398, 402, -30, -6)
	p.global_position = Vector2(400*16+8, -28*16); p.velocity = Vector2.ZERO
	await _step(45)
	print("SUBMERGED fall vy after 45f = %.1f (cap ~90, dry would be ~300)" % p.velocity.y)

	print("DONE")
	quit()
