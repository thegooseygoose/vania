extends SceneTree
## Verifies the new paintable SAVE_TILE_ATLAS (85): boots Level4, paints a fresh marker tile
## onto an empty Powerups cell, re-runs the tile scan, and confirms (1) a real SaveStation
## spawned there, (2) the marker tile itself got erased (no double-drawing/overlap), (3) the
## spawned station behaves like any other (solid + press-up-to-save).

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 4
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var before: int = m.save_stations.size()
	print("save_stations before: %d" % before)

	var cell := Vector2i(60, 10)   # pick a cell far from the level's existing content
	if m.powerups_layer.get_cell_source_id(cell) != -1:
		print("FAIL: test cell already occupied, pick another")
		quit(); return
	m.powerups_layer.set_cell(cell, 0, Vector2i(85, 0))
	m._spawn_switch_tiles()

	print("save_stations after paint+rescan: %d" % m.save_stations.size())
	print("marker tile erased (no overlap): %s" % str(m.powerups_layer.get_cell_source_id(cell) == -1))

	var sv = m.save_stations[m.save_stations.size() - 1]
	print("new station at %s (expected %s)" % [str(sv.global_position), str(Vector2(cell.x*16+8, cell.y*16+8))])

	# drop the player onto it and confirm it behaves like a normal save station
	m.player.global_position = sv.global_position + Vector2(0, -60)
	m.player.velocity = Vector2.ZERO
	for i in range(90): await physics_frame
	print("settled on new tile-spawned station: on_floor=%s near=%s" % [str(m.player.is_on_floor()), str(sv._near)])
	Input.action_press("move_up")
	await physics_frame
	Input.action_release("move_up")
	for i in range(5): await physics_frame
	print("pressed UP: checkpoint_active=%s checkpoint_pos=%s" % [str(m.checkpoint_active), str(m.checkpoint_pos)])
	quit()
