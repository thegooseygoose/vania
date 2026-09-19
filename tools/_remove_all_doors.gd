extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	var removed := 0
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28:
			et.erase_cell(c)
			removed += 1
	print("removed %d door-part cells (all doors now fully open passages)" % removed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
