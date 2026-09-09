extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=12   # Level 28
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	# add two sectors: A a small box, B a big room, to the level
	var S=load("res://sector.gd")
	var a=S.new(); a.position=Vector2(20*16, 5*16); a.w_tiles=10; a.h_tiles=8   # small box
	var b=S.new(); b.position=Vector2(40*16, 2*16); b.w_tiles=40; b.h_tiles=20  # big room
	m.level.add_child(a); m.level.add_child(b)
	m._wire_powerups()   # re-collect sectors
	print("uses_rooms=%s sectors=%d section_count=%d"%[str(m.uses_rooms()), m._sector_rects.size(), m.section_count()])
	# player inside A
	m.player.global_position=Vector2(25*16, 8*16)
	var rA=m.current_room_rect()
	print("in A: room_rect=%s section=%d"%[str(rA), m.current_section()])
	for i in range(60): await physics_frame
	print("  cam after settle: (%.0f,%.0f)  A_px=(%d,%d,%d,%d)"%[m.cam_x,m.cam_y, 20*16,5*16,10*16,8*16])
	# player inside B
	m.player.global_position=Vector2(55*16, 12*16)
	var rB=m.current_room_rect()
	print("in B: room_rect=%s section=%d"%[str(rB), m.current_section()])
	quit()
