extends SceneTree
## Non-destructive append: adds ONE more powerup tile (LONG BEAM, atlas 83) to Level30's armory
## at (56,13) -- just past the first divider wall's floor, well before the zoomer enemy at (65,13).
## Touches nothing else.
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level30.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	pw.set_cell(Vector2i(56, 13), 0, Vector2i(83, 0))
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level30.tscn")
	print("added LONG BEAM armory tile at (56,13), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
