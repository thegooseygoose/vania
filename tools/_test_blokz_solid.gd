extends SceneTree
## Verifies the BLOKZ tiles (atlas 67/68) are now real solid ground: drops the player from just
## above the BLOKZ cluster placed near Level29 spawn (x=28-30, y=200-205) and checks it lands ON
## TOP of a block instead of falling through to the real floor at y~208.
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13  # BR/Level29
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(40): await physics_frame
	if not m.player:
		print("NO PLAYER"); quit(); return
	# teleport player above the atlas-68 breakable block at (29,205) -> world (29*16+8, 204*16)
	m.player.global_position = Vector2(29*16+8, 195*16)
	m.player.velocity = Vector2.ZERO
	for i in range(60): await physics_frame
	var p = m.player.global_position
	print("landed at y=%.1f (expect ~%d if standing ON the block at row205, ~%d+ if fell through to the real floor)" % [
		p.y, 205*16, 208*16])
	quit()
