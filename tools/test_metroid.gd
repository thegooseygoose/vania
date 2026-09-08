extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=28
	var main=load("res://Main.tscn").instantiate(); get_root().add_child(main)
	for i in range(40): await physics_frame
	main.start_delay=0.0; main.fade_alpha=0.0
	var p=main.player; p.global_position=Vector2(300,200); p.velocity=Vector2.ZERO
	for i in range(4): await physics_frame
	var E=load("res://enemy.gd"); var m=E.new(); m.main=main; m.kind="metroid"
	main.add_child(m); m.spawn(Vector2(500,120)); m.active=true; main.enemies.append(m)
	var d0=m.global_position.distance_to(p.global_position)
	for i in range(60): await physics_frame
	var d1=m.global_position.distance_to(p.global_position)
	print("homing: dist %.0f -> %.0f (closer=%s)  hp=%d" % [d0,d1,str(d1<d0),m.boss_hp])
	for s in range(12):
		m.boomerang_kill(1)
	print("after 12 shots: dead=%s hp=%d" % [str(m.dead), m.boss_hp])
	quit()
