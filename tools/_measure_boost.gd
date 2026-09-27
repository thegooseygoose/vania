extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_morph = true; p.has_boostball = true
	p.global_position = Vector2(2*16, 13*16 - 14); p.velocity = Vector2.ZERO
	for i in range(30): await physics_frame
	Input.action_press("move_down"); await physics_frame; Input.action_release("move_down")
	for i in range(20): await physics_frame
	print("morphed=%s floor=%s y=%.1f" % [str(p.morphed), str(p.is_on_floor()), p.global_position.y])
	var x0: float = p.global_position.x
	Input.action_press("run")
	for i in range(40): await physics_frame
	print("charging: charge=%.2f boosting=%s" % [p.boost_charge, str(p.boosting)])
	for i in range(40): await physics_frame
	Input.action_release("run")
	var maxdx := 0.0; var maxy: float = p.global_position.y
	for i in range(80):
		await physics_frame
		maxdx = maxf(maxdx, p.global_position.x - x0)
		maxy = maxf(maxy, p.global_position.y)
	print("BOOST: dx=%.0f px (%.1f tiles) y drop=%.0f" % [maxdx, maxdx/16.0, maxy - (13*16-8)])
	quit()
