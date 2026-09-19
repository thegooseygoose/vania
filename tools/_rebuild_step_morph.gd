extends SceneTree
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	var et = scn.get_node("EnemyTiles")
	pw.set_cell(Vector2i(24, 206), 0, Vector2i(48, 0))   # user's final manual morph placement
	et.erase_cell(Vector2i(16, 207))
	et.erase_cell(Vector2i(26, 198))
	print("set morph pickup + removed 2 nearby viruses")
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
