extends SceneTree
## Spawns a bug below the player in Level Z and checks it rises to head height then chases.
## Run: --headless --path . -s tools/test_bug.gd

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
	p.global_position = Vector2(200, 200)
	p.velocity = Vector2.ZERO
	for i in range(6): await physics_frame

	var Enemy = load("res://enemy.gd")
	var b = Enemy.new()
	b.main = main
	b.kind = "bug"
	main.add_child(b)
	b.spawn(Vector2(260, 300))          # spawn ~100px BELOW & to the right of the player
	b.active = true
	main.enemies.append(b)
	var head_y: float = p.global_position.y - p.col_size.y * 0.5 - 3.0
	print("spawn bug at y=%.0f (player head_y=%.0f, player_x=%.0f)" % [b.global_position.y, head_y, p.global_position.x])

	for step in range(6):
		for i in range(40): await physics_frame
		print("t+%d: bug pos=(%.0f,%.0f) risen=%s  dx_to_player=%.0f" % [
			(step+1)*40, b.global_position.x, b.global_position.y, str(b.bug_risen),
			p.global_position.x - b.global_position.x])
	# final assertions
	var at_head := absf(b.global_position.y - head_y) < 8.0
	var near_x := absf(p.global_position.x - b.global_position.x) < 20.0
	print("RESULT: rose_to_head=%s  chased_to_player=%s" % [str(at_head), str(near_x)])
	quit()
