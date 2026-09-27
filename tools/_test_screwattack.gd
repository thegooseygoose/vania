extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 16
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	print("pickups: %s" % str(m.powerup_tile_cells.map(func(c): return c[1])))
	var p = m.player
	p.has_screwattack = true
	# spawn a plain goomba-like enemy to test contact
	var e = Enemy.new(); e.main = m; m.add_child(e); e.spawn(Vector2(500, 200)); m.enemies.append(e)
	# 1) AIRBORNE contact: should kill the enemy, not hurt the player
	p.global_position = Vector2(500, 150); p.velocity = Vector2(0, 50)
	print("airborne screw_active=%s enemy dead(before)=%s" % [str(p.screw_active()), str(e.dead)])
	var hp0: int = p.hp
	for i in range(20): await physics_frame
	print("AFTER AIRBORNE CONTACT: enemy dead=%s player hp %d->%d" % [str(e.dead), hp0, p.hp])
	# 2) GROUND contact with a fresh enemy: should hurt the player normally (screw only works airborne)
	var e2 = Enemy.new(); e2.main = m; m.add_child(e2); e2.spawn(Vector2(100, 200)); m.enemies.append(e2)
	p.invuln = 0.0
	p.global_position = Vector2(100, 13*16 - p.col_size.y/2.0); p.velocity = Vector2.ZERO
	for i in range(40): await physics_frame
	print("on floor=%s screw_active=%s" % [str(p.is_on_floor()), str(p.screw_active())])
	var hp1: int = p.hp
	for i in range(10): await physics_frame
	print("AFTER GROUND CONTACT: enemy2 dead=%s player hp %d->%d" % [str(e2.dead), hp1, p.hp])
	# 3) sprite spin check while airborne
	p.global_position = Vector2(300, 100); p.velocity = Vector2(0, 20)
	var r0: float = p.sprite.rotation
	for i in range(10): await physics_frame
	print("SPIN: rotation changed while airborne: %s (r0=%.2f r1=%.2f)" % [str(p.sprite.rotation != r0), r0, p.sprite.rotation])
	quit()
