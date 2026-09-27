extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 15
	m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(30): await physics_frame
	var p = m.player
	p.has_dash = true
	p.global_position = Vector2(8*16, 5*16); p.velocity = Vector2.ZERO   # high in the air
	p.facing = 1
	for i in range(6): await physics_frame
	var x0: float = p.global_position.x; var y0: float = p.global_position.y
	print("airborne before dash: floor=%s vy=%.0f" % [str(p.is_on_floor()), p.velocity.y])
	Input.action_press("dash"); await physics_frame; Input.action_release("dash")
	var was_dashing: bool = p.dashing
	var maxdy := 0.0
	for i in range(14):
		await physics_frame
		maxdy = maxf(maxdy, absf(p.global_position.y - y0))
	print("AIR DASH: started=%s dx=%.0f px dy=%.1f px (flat lunge, no gravity)" % [str(was_dashing), p.global_position.x - x0, maxdy])
	quit()
