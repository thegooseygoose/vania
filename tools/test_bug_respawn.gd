extends SceneTree
## Spawns a bug, kills it, and checks it respawns at its origin. Run: --headless --path . -s tools/test_bug_respawn.gd

func _initialize(): call_deferred("_run")

func _run() -> void:
	Main.attract_mode = false
	Main.save_slot = -1
	Main.debug_start_level = 28
	var main = load("res://Main.tscn").instantiate()
	get_root().add_child(main)
	for i in range(40): await physics_frame
	main.start_delay = 0.0
	main.fade_alpha = 0.0
	var p = main.player
	p.global_position = Vector2(200, 200); p.velocity = Vector2.ZERO
	for i in range(4): await physics_frame

	var Enemy = load("res://enemy.gd")
	var b = Enemy.new(); b.main = main; b.kind = "bug"
	main.add_child(b); b.spawn(Vector2(260, 300)); b.active = true; main.enemies.append(b)
	var origin = b.bug_spawn_pos
	print("origin=", origin)
	# let it rise/chase a bit
	for i in range(80): await physics_frame
	print("alive: pos=(%.0f,%.0f) dead=%s risen=%s" % [b.global_position.x, b.global_position.y, str(b.dead), str(b.bug_risen)])
	# KILL it
	b.knock_out(1)
	print("killed: dead=%s" % str(b.dead))
	# wait past the respawn delay
	for i in range(110): await physics_frame
	print("after respawn window: dead=%s risen=%s pos=(%.0f,%.0f) at_origin=%s in_list=%s" % [
		str(b.dead), str(b.bug_risen), b.global_position.x, b.global_position.y,
		str(b.global_position.distance_to(origin) < 2.0), str(b in main.enemies)])
	quit()
