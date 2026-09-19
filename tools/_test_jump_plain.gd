extends SceneTree
## Sanity check: does a plain jump work at all on ordinary flat ground (away from
## the shaft), to rule out a global regression vs. something specific to the ladder area.
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	print("spawn pos=", m.player.global_position, " on_floor=", m.player.is_on_floor())
	m.player.jump_held = false
	var start_y: float = m.player.global_position.y
	Input.action_press("jump")
	var min_y: float = start_y
	for f in range(1, 90):
		await physics_frame
		min_y = minf(min_y, m.player.global_position.y)
		if f % 10 == 0 or f < 3:
			print("f=%d pos=%s vel=%s on_floor=%s" % [f, str(m.player.global_position), str(m.player.velocity), str(m.player.is_on_floor())])
	Input.action_release("jump")
	print("APEX rise = %.2f px = %.2f tiles" % [start_y - min_y, (start_y - min_y) / 16.0])
	quit()
