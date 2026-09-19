extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay = 0.0; m.fade_alpha = 0.0
	m.player.has_boomerang = true
	m.player.global_position = Vector2(530 * 16, 380 * 16)   # TALON arena, wide open (tall room)
	m.player.velocity = Vector2(0, 150)   # already falling fast, like mid-jump on the way down
	m.player.facing = 1
	for i in range(3): await physics_frame

	print("BEFORE fire: velocity.y=", m.player.velocity.y, " grounded=", m.player.grounded)
	m.player._fire_shot(false)
	print("AFTER fire (same frame): velocity.y=", m.player.velocity.y, " (expect ~150, unchanged)")

	# now test the grounded case still gets the floaty pop
	m.player.global_position = Vector2(530 * 16, 408 * 16)   # near the arena floor
	m.player.velocity = Vector2.ZERO
	for i in range(15): await physics_frame   # let him settle onto the floor
	print("settled: grounded=", m.player.grounded, " velocity.y=", m.player.velocity.y)
	m.player._fire_shot(false)
	print("AFTER fire while grounded: velocity.y=", m.player.velocity.y, " (expect ~-65, the floaty pop)")
	print("DONE")
	quit()
