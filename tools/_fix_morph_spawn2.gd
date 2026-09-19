extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	# verify current state first
	var cells = pw.get_used_cells()
	var has_spawn_tile = false
	var has_moved_tile = false
	for c in cells:
		if c == Vector2i(40,206) and pw.get_cell_atlas_coords(c).x == 48: has_spawn_tile = true
		if c == Vector2i(17,206) and pw.get_cell_atlas_coords(c).x == 48: has_moved_tile = true
	print("BEFORE fix-check: spawn_tile_present=%s moved_tile_present=%s total_powerup_cells=%d" % [has_spawn_tile, has_moved_tile, cells.size()])
	# also verify enemies/coins survived the previous save
	var enemies = scn.get_node("Spawns/Enemies")
	var coins = scn.get_node("Spawns/Coins")
	print("Enemies children=%d Coins children=%d" % [enemies.get_child_count(), coins.get_child_count()])
	quit()
