extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var et = scn.get_node("EnemyTiles")
	# 5 embedded-in-wall enemies (leftover from terrain edits since the last cleanup)
	var embedded := [Vector2i(52,416), Vector2i(68,387), Vector2i(99,357), Vector2i(114,327), Vector2i(132,282)]
	# 7 enemies within 4 tiles of a door (ambush-at-transition fairness)
	var near_door := [Vector2i(189,93), Vector2i(101,347), Vector2i(99,377), Vector2i(116,256),
		Vector2i(116,348), Vector2i(132,250), Vector2i(130,384)]
	var removed := 0
	for c in embedded + near_door:
		if et.get_cell_source_id(c) != -1:
			et.erase_cell(c)
			removed += 1
	print("removed %d enemy tiles" % removed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
