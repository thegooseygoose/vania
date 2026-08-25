extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	# paint an atlas-16 switch tile, then re-scan
	var cell=Vector2i(60,10)
	m.terrain.set_cell(cell, m.SOURCE_ID, Vector2i(16,0))
	print("painted atlas at (60,10) =", m.terrain.get_cell_atlas_coords(cell).x, " (want 16)")
	var before=m.door_switches.size()
	m._spawn_switch_tiles()
	print("switches from tiles: +%d  tile erased now? %s" % [m.door_switches.size()-before, str(m.terrain.get_cell_source_id(cell)<0)])
	# throw boomerang at the new switch
	var sw=m.door_switches[m.door_switches.size()-1]; var dr=m.doors[0]
	var p=m.player; p.has_boomerang=true
	p.global_position=sw.global_position+Vector2(-40,0); p.velocity=Vector2.ZERO; p.facing=1
	await _step(3)
	Input.action_press("boomerang"); await _step(2); Input.action_release("boomerang")
	for i in range(50): await physics_frame
	print("boomerang hit tile-switch: triggered=%s  door opened=%s" % [str(sw.triggered), str(dr.opened)])
	print("DONE"); quit()
