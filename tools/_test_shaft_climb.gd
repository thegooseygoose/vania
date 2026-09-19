extends SceneTree
## Real-engine test: actually drives the player up the rebuilt zigzag staircase
## (x162-173, y165-194) via simulated input, not just the abstract BFS.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	# rebuild the same step list the builder used
	var X_MIN := 163; var X_MAX := 172
	var Y_TOP := 165; var Y_BOT := 194
	var x := X_MAX; var y := Y_BOT; var dir := -1
	var steps: Array = []
	while y >= Y_TOP:
		steps.append(Vector2i(x, y))
		x += dir
		if x < X_MIN: x = X_MIN; dir = 1
		elif x > X_MAX: x = X_MAX; dir = -1
		y -= 1

	var wps: Array = []
	for s in steps:
		wps.append(Vector2(s.x * 16 + 8, (s.y - 1) * 16 + 8))  # stand just above each step

	m.player.global_position = wps[0]
	m.player.velocity = Vector2.ZERO
	for i in range(10): await physics_frame
	print("start pos=", m.player.global_position, " on_floor=", m.player.is_on_floor())

	for wi in range(1, wps.size()):
		var target: Vector2 = wps[wi]
		var frame := 0
		var arrived := false
		while frame < 120:
			frame += 1
			var d: Vector2 = target - m.player.global_position
			if d.x > 2.0:
				Input.action_press("move_right"); Input.action_release("move_left")
			elif d.x < -2.0:
				Input.action_press("move_left"); Input.action_release("move_right")
			else:
				Input.action_release("move_left"); Input.action_release("move_right")
			Input.action_release("jump")
			await physics_frame
			if m.player.global_position.distance_to(target) < 10.0:
				arrived = true
				break
			if m.player.global_position.y > (Y_BOT + 6) * 16:
				print("FELL TOO FAR at waypoint %d pos=%s" % [wi, str(m.player.global_position)])
				quit(1)
				return
		if not arrived:
			print("STUCK at waypoint %d target=%s final pos=%s vel=%s on_floor=%s" %
				[wi, str(target), str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
			quit(1)
			return
	print("SUCCESS: climbed the whole staircase, final pos=%s (target top ~y=%d)" % [str(m.player.global_position), Y_TOP])
	quit()
