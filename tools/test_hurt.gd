extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot = -1; Main.debug_start_level = 1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay = 0.0; m.fade_alpha = 0.0
	var p = m.player

	# ball texture built from ball2.png?
	var bt = p._ball_tex
	print("MORPH ball tex = %s (%dx%d)" % ["ok" if bt else "NULL", bt.get_width() if bt else 0, bt.get_height() if bt else 0])

	# knockback: face right, take a hit -> shoved LEFT + up, control locked, invuln + flashing
	p.facing = 1
	p.velocity = Vector2.ZERO
	var h0 = p.hearts
	p.hurt()
	print("after hurt: hearts %d->%d  vx=%.0f (want <0)  vy=%.0f (want <0)  hurt_lock=%.2f  invuln=%.2f" % [h0, p.hearts, p.velocity.x, p.velocity.y, p.hurt_lock, p.invuln])

	# flashing: over ~0.4s the sprite visibility should toggle several times
	var flips := 0
	var last = p.sprite.visible
	for i in range(30):
		await physics_frame
		if p.sprite.visible != last:
			flips += 1; last = p.sprite.visible
	print("sprite visibility flips during invuln = %d (want > 0)" % flips)

	# face left, hit -> shoved RIGHT
	await _step(120)                 # let invuln expire
	p.facing = -1; p.velocity = Vector2.ZERO
	p.hurt()
	print("facing left hit: vx=%.0f (want >0)" % p.velocity.x)
	print("DONE")
	quit()
