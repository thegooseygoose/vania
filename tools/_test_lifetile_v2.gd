extends SceneTree
## Boots Level30, verifies the painted life-refill tile (atlas 84, Powerups layer): stays
## painted (not erased), only engages while hurt, heals over time with heal_lock + sound,
## and releases when full/away. Also confirms full-HP players get nothing.

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	print("life_tile_cells=%s" % [str(m.life_tile_cells)])
	if m.life_tile_cells.is_empty():
		print("FAIL: no life tile registered")
		quit(); return
	var cell: Vector2i = m.life_tile_cells[0]
	var c := Vector2(cell.x * 16 + 8, cell.y * 16 + 8)
	# tile should still be painted (persistent, not erased like a normal powerup)
	print("tile still painted: %s" % str(m.powerups_layer.get_cell_source_id(cell) != -1))

	# FULL HP: should do nothing
	m.player.hp = m.player.MAX_HP
	m.player.global_position = c
	for i in range(10): await physics_frame
	print("FULL HP on tile: heal_lock=%s hp=%s" % [str(m.player.heal_lock), str(m.player.hp)])

	# HURT: should lock + heal + play sound
	m.player.hp = 40
	for i in range(60): await physics_frame   # 1s -> +20
	print("hurt 1s on tile: hp=%s heal_lock=%s sfx_playing=%s"
		% [str(m.player.hp), str(m.player.heal_lock), str(m._life_fill_sfx != null and m._life_fill_sfx.playing)])

	# walk away: should release + stop sound
	m.player.global_position = c + Vector2(300, 0)
	for i in range(10): await physics_frame
	print("stepped away: heal_lock=%s sfx=%s" % [str(m.player.heal_lock), str(m._life_fill_sfx)])

	# tile still there after all that use
	print("tile STILL painted after use: %s" % str(m.powerups_layer.get_cell_source_id(cell) != -1))
	quit()
