extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13   # Level 29 (Metroid world, big rooms)
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player.global_position
	var E=load("res://enemy.gd"); var v=E.new(); v.main=m; v.kind="virus"
	m.add_child(v); v.spawn(Vector2(p.x+48, p.y-48)); v.active=true; m.enemies.append(v)
	print("spawn near player=(%.0f,%.0f): virus size=%s vel.x=%.0f"%[p.x,p.y,str(v.rect.size),v.velocity.x])
	var x0=v.global_position.x
	for step in range(6):
		for i in range(25): await physics_frame
		print("t+%d: x=%.0f dir=%d vx=%.0f on_floor=%s on_wall=%s"%[(step+1)*25, v.global_position.x, v.dir, v.velocity.x, str(v.is_on_floor()), str(v.is_on_wall())])
	print("RESULT: moved_%.0fpx"%(v.global_position.x-x0))
	quit()
