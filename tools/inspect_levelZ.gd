extends SceneTree
## Boots Level Z (file 28) and dumps its actual content for a design review:
## bounds, rooms/sections, doors, enemies, power-up tiles, goal, coins, special tiles.
## Run: --headless --path . -s tools/inspect_levelZ.gd

func _initialize(): call_deferred("_run")

func _run() -> void:
	Main.attract_mode = false
	Main.save_slot = -1
	Main.debug_start_level = 28
	var main = load("res://Main.tscn").instantiate()
	get_root().add_child(main)
	for i in range(40): await physics_frame
	main.start_delay = 0.0
	main.fade_alpha = 0.0
	for i in range(5): await physics_frame

	var TILE: int = main.TILE
	print("=== LEVEL Z (file 28) ===")
	print("level_file=", main._level_file, "  uses_rooms=", main.uses_rooms())
	print("bounds px: left=%.0f right=%.0f top=%.0f bottom=%.0f  (W=%.0f H=%.0f)" % [
		main.lvl_left, main.lvl_right, main.lvl_top, main.lvl_bottom,
		main.lvl_right - main.lvl_left, main.lvl_bottom - main.lvl_top])
	print("width in tiles ~", int((main.lvl_right - main.lvl_left) / TILE),
		"  height in tiles ~", int((main.lvl_bottom - main.lvl_top) / TILE))
	print("sections (rooms) = ", main.section_count())
	if "_segments" in main:
		var i := 0
		for s in main._segments:
			print("  room %d: x %.0f..%.0f  (%.0f px = %.1f screens)" % [
				i + 1, s[0], s[1], s[1] - s[0], (s[1] - s[0]) / float(main.VIEW_W)])
			i += 1
	print("door pairs = ", main.door_pairs.size())

	# enemies
	print("--- enemies (", main.enemies.size(), ") ---")
	var by_kind := {}
	for e in main.enemies:
		by_kind[e.kind] = by_kind.get(e.kind, 0) + 1
	for k in by_kind:
		print("  ", k, " x", by_kind[k])
	for e in main.enemies:
		print("    %s @ tile (%d,%d)" % [e.kind, int(e.global_position.x / TILE), int(e.global_position.y / TILE)])

	# power-up tiles / nodes
	print("--- powerups collected available ---")
	var pcount := 0
	for n in main.get_tree().get_nodes_in_group("__none__"):
		pass
	# scan the Powerups layer for painted ability tiles 48..59
	var terr = main.terrain
	var pl = main.get_node_or_null("Level/LevelZ/Powerups")
	print("goal cells = ", main.goal_cells.size() if "goal_cells" in main else "n/a")

	# scan every layer for a tile-atlas histogram (terrain + specials)
	_scan_layer(main, "Terrain", TILE)
	quit()

func _scan_layer(main, layer_name: String, TILE: int) -> void:
	# the level root is the parent of the Terrain TileMapLayer
	var root_lvl = main.terrain.get_parent() if main.terrain else null
	if root_lvl == null:
		print("(no level root)")
		return
	for lname in ["Terrain", "Markers", "Powerups", "EnemyTiles", "CoinTiles"]:
		var node = root_lvl.get_node_or_null(lname)
		if node == null:
			continue
		var cells = node.get_used_cells()
		var hist := {}
		for c in cells:
			var ax: int = node.get_cell_atlas_coords(c).x
			hist[ax] = hist.get(ax, 0) + 1
		print("--- layer %s: %d cells, atlas histogram ---" % [lname, cells.size()])
		var keys = hist.keys()
		keys.sort()
		for ax in keys:
			print("    atlas %d : %d" % [ax, hist[ax]])
