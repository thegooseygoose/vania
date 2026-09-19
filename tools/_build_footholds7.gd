extends SceneTree
## Precise fix found via _debug_stand.gd ground truth (not ASCII eyeballing): x169 has a genuine
## grounded floor at y291 (sol y292) but three separate 1-tile solid blockers at y285, y287, y288
## sit directly above, each independently capping the climb (JH=4 from y291 only reaches y289
## before hitting the y288 blocker -- matches the observed X-ceiling at y289 exactly). Clearing
## all three should open a continuous path up into the fwd-conquered region above.
var terr
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	terr.erase_cell(Vector2i(169, 285))
	terr.erase_cell(Vector2i(169, 287))
	terr.erase_cell(Vector2i(169, 288))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds7 (clear x169 y285/287/288), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
