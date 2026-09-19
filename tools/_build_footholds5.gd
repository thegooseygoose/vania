extends SceneTree
## Re-grounding platform in the big open room's center (x110-160/y285-299, confirmed empty via
## _dump_reach.gd -- neither fwd nor bwd has a recorded standable state there despite it being
## open, classic "big empty pit, need an anchor" case, same as footholds2).
const WALL := 13
var terr
func _platform(x0: int, x1: int, y: int) -> void:
	for x in range(x0, x1 + 1):
		terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))
		terr.erase_cell(Vector2i(x, y - 1))
		terr.erase_cell(Vector2i(x, y - 2))
		terr.erase_cell(Vector2i(x, y - 3))
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	_platform(130, 140, 293)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds5 (x130-140 platform, y292/293), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
