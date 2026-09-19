extends SceneTree
## Replaces Level30's old EnemyTiles life-station tile (atlas 39, now removed) with a proper
## Powerups-layer icon (atlas 84, 16x16, persistent -- like the other power-up tiles).

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level30.tscn").instantiate()

	var et = scn.get_node("EnemyTiles")
	var old_cell := Vector2i(352, 13)
	if et.get_cell_source_id(old_cell) != -1:
		et.erase_cell(old_cell)
		print("erased old EnemyTiles life-station cell at %s" % str(old_cell))

	var pw = scn.get_node("Powerups")
	pw.set_cell(old_cell, 0, Vector2i(84, 0))
	print("painted life-refill icon (atlas 84) at %s" % str(old_cell))

	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level30.tscn")
	print("saved Level30.tscn err=%d" % err)
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
