extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 16
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_screwattack = true
	p.global_position = Vector2(100, 13*16 - p.col_size.y/2.0); p.velocity = Vector2.ZERO
	for i in range(40): await physics_frame
	print("settled on_floor=%s screw_active=%s" % [str(p.is_on_floor()), str(p.screw_active())])
	var e = Enemy.new(); e.main = m; m.add_child(e); e.spawn(Vector2(400, 200)); m.enemies.append(e)
	e.global_position = p.global_position   # teleport the enemy ONTO the already-grounded player
	var hp0: int = p.hp
	for i in range(10): await physics_frame
	print("STAND+TELEPORT ENEMY ONTO PLAYER: enemy dead=%s player hp %d->%d" % [str(e.dead), hp0, p.hp])
	quit()
