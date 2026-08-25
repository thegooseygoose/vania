extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame
func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40); m.start_delay=0.0; m.fade_alpha=0.0
	# paint a switch (16) and a 1x3 door (17)
	m.terrain.set_cell(Vector2i(60,10), m.SOURCE_ID, Vector2i(16,0))
	for y in [9,10,11]: m.terrain.set_cell(Vector2i(64,y), m.SOURCE_ID, Vector2i(17,0))
	m.door_switches.clear()
	m._spawn_switch_tiles()
	print("switches=%d  door_tiles tracked=%d" % [m.door_switches.size(), m.door_tile_cells.size()])
	print("door tile (64,10) solid before? %s (want true)" % str(m.terrain.get_cell_source_id(Vector2i(64,10))>=0))
	# boomerang the switch
	var sw=m.door_switches[m.door_switches.size()-1]
	var p=m.player; p.has_boomerang=true
	p.global_position=sw.global_position+Vector2(-40,0); p.velocity=Vector2.ZERO; p.facing=1
	await _step(3)
	Input.action_press("boomerang"); await _step(2); Input.action_release("boomerang")
	for i in range(50): await physics_frame
	var gone = m.terrain.get_cell_source_id(Vector2i(64,9))<0 and m.terrain.get_cell_source_id(Vector2i(64,10))<0 and m.terrain.get_cell_source_id(Vector2i(64,11))<0
	print("after boomerang: switch triggered=%s  door tiles gone=%s (want true)" % [str(sw.triggered), str(gone)])
	print("DONE"); quit()
