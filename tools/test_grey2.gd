extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=12
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	m._sector_rects=[Rect2(20*16,0,15*16,20*16)]
	var DP=load("res://doorpart.gd")
	var d=DP.new(); d.main=m; d.locked=true; d.part=DP.Part.LEFT
	m.level.add_child(d); d.global_position=Vector2(25*16,10*16)
	m.grey_doors=[d]; m.door_parts=[d]
	for i in range(3): await physics_frame
	var E=load("res://enemy.gd"); var v=E.new(); v.main=m; v.kind="virus"
	m.add_child(v); v.spawn(Vector2(28*16,10*16)); v.active=true; m.enemies=[v]
	m._update_locked_doors()
	print("1) enemy alive: locked=%s shot=%s"%[str(d.locked),str(d._shot)])
	v.dead=true; m._update_locked_doors()
	print("2) sector cleared: locked=%s shot=%s flashing=%s (expect locked=false, shot=false, flash>0)"%[str(d.locked),str(d._shot),str(d._flash_t>0.0)])
	d.shoot()
	print("3) now shot: shot=%s (expect true — opens as a blue door)"%str(d._shot))
	quit()
