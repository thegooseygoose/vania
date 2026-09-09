extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=12
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	# define a sector rect (tiles 20-35, rows 0-20) and a grey door half inside it
	var sec=Rect2(20*16, 0, 15*16, 20*16)
	m._sector_rects=[sec]
	var DP=load("res://doorpart.gd")
	var d=DP.new(); d.main=m; d.locked=true; d.part=DP.Part.LEFT
	m.level.add_child(d); d.global_position=Vector2(25*16, 10*16)
	m.grey_doors=[d]; m.door_parts.append(d)
	for i in range(3): await physics_frame
	# an enemy inside the sector
	var E=load("res://enemy.gd"); var v=E.new(); v.main=m; v.kind="virus"
	m.add_child(v); v.spawn(Vector2(28*16, 10*16)); v.active=true; m.enemies=[v]
	m._update_locked_doors()
	print("enemy alive -> door _shot=%s (expect false, locked)"%str(d._shot))
	# kill the enemy
	v.dead=true
	m._update_locked_doors()
	print("enemy dead -> door _shot=%s (expect true, opened)"%str(d._shot))
	quit()
