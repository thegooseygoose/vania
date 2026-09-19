extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var doors := []
	var enemies := []
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: doors.append(c)
		elif ax in [24,25,29,31,35]: enemies.append(c)
	var removed := 0
	for c in enemies:
		for d in doors:
			if absf(c.x - d.x) <= 4 and absf(c.y - d.y) <= 2:
				et.erase_cell(c)
				removed += 1
				break
	print("removed %d door-ambush enemies (within 4 tiles of a door)" % removed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
