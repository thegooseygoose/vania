extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	var p=m.player.global_position
	var E=load("res://enemy.gd"); var v=E.new(); v.main=m; v.kind="virus"
	m.add_child(v); v.spawn(Vector2(p.x+40,p.y-40)); v.active=true; m.enemies.append(v)
	for i in range(30): await physics_frame   # let it land
	for s in range(1,6):
		v.boomerang_kill(1)
		print("shot %d: virus_hp=%d dead=%s melting=%s"%[s, v.virus_hp, str(v.dead), str(v.melting)])
		for i in range(2): await physics_frame
	# let the melt play out
	for i in range(60): await physics_frame
	print("after melt: remove_me=%s scale=%s"%[str(v.remove_me), str(v.sprite.scale) if is_instance_valid(v) else "freed"])
	quit()
