extends SceneTree
## Boots Level4 (has SaveStation nodes), drops the player from above one, and confirms they
## come to rest ON TOP of its solid block (not falling through, not getting stuck below it).

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 4
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var save = null
	for n in m.level.get_children():
		if n is SaveStation:
			save = n
	if save == null:
		print("FAIL: no SaveStation found")
		quit(); return
	var block_top: float = save.global_position.y - 8.0
	print("SaveStation at %s, block top y=%s" % [str(save.global_position), str(block_top)])

	m.player.global_position = save.global_position + Vector2(0, -60)
	m.player.velocity = Vector2.ZERO
	for i in range(90): await physics_frame   # 1.5s to fall and settle
	print("player after falling: y=%s on_floor=%s vy=%s"
		% [str(m.player.global_position.y), str(m.player.is_on_floor()), str(m.player.velocity.y)])
	print("expected to rest near block top (%s minus half player height)" % str(block_top))
	quit()
