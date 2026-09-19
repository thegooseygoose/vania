extends SceneTree
## Replaces the hand-placed Life1 Area2D node in Level30 with a PAINTED EnemyTiles tile
## (atlas col 39, the new life-station icon) at the same spot -- so it spawns via the normal
## paintable-tile pipeline (main.gd _spawn_enemies) instead of being a manually placed node.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level30.tscn").instantiate()

	var old = scn.get_node_or_null("Life1")
	if old:
		scn.remove_child(old)
		old.queue_free()
		print("removed old Life1 node")

	var et = scn.get_node("EnemyTiles")
	var cell := Vector2i(352, 13)   # same floor spot, a few tiles before the goal (359,13)
	et.set_cell(cell, 0, Vector2i(39, 0))
	print("painted life_station tile at %s" % str(cell))

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
