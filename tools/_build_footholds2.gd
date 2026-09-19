extends SceneTree
## Bridges the x110-175/y328-336 gap identified via _dump_reach.gd: bwd's JH=4+doublejump combo
## (max 8 tiles) reaches exactly from standable y344 (floor y345) up to airborne y336, matching
## the observed X/./F boundary precisely. Needs 16 total to reach the F-region at y328 (through a
## real gap at x125-126,y328-329, confirmed open in the terrain). One re-grounding platform at
## y336 (solid y337), aligned with that gap column, splits it into two 8-tile combos.
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
	_platform(123, 127, 337)
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built footholds2 (x123-127 platform, y336/337), saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
