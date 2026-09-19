extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	m.player.has_boomerang = true
	m.player.global_position = Vector2(530 * 16, 400 * 16)   # TALON arena, wide open
	m.player.velocity = Vector2.ZERO
	m.player.facing = 1
	for i in range(10): await physics_frame

	# --- straight up (no horizontal key held) ---
	Input.action_press("move_up")
	for i in range(3): await physics_frame
	m.player._fire_shot(false)
	var b = m.player.boomerangs[-1]
	print("straight up: aim=", b.aim, " (expect ~(0,-1))")
	Input.action_release("move_up")
	for i in range(30): await physics_frame

	# --- diagonal up-right (move_up + move_right) ---
	Input.action_press("move_up")
	Input.action_press("move_right")
	for i in range(3): await physics_frame
	m.player._fire_shot(false)
	b = m.player.boomerangs[-1]
	var start_pos: Vector2 = b.global_position
	print("diag up-right: aim=", b.aim, " (expect ~(0.707,-0.707))")
	for i in range(10): await physics_frame
	if is_instance_valid(b):
		print("  after 10 frames, moved: ", b.global_position - start_pos, " (expect +x,-y both nonzero, roughly equal magnitude)")
	Input.action_release("move_up"); Input.action_release("move_right")
	for i in range(30): await physics_frame

	# --- diagonal up-left (move_up + move_left) ---
	Input.action_press("move_up")
	Input.action_press("move_left")
	for i in range(3): await physics_frame
	m.player._fire_shot(false)
	b = m.player.boomerangs[-1]
	start_pos = b.global_position
	print("diag up-left: aim=", b.aim, " (expect ~(-0.707,-0.707))")
	for i in range(10): await physics_frame
	if is_instance_valid(b):
		print("  after 10 frames, moved: ", b.global_position - start_pos, " (expect -x,-y both nonzero, roughly equal magnitude)")
	Input.action_release("move_up"); Input.action_release("move_left")
	for i in range(5): await physics_frame

	# --- plain horizontal (unchanged) ---
	m.player._fire_shot(false)
	b = m.player.boomerangs[-1]
	print("horizontal: aim=", b.aim, " (expect (1,0), facing=1)")
	print("DONE")
	quit()
