extends SceneTree
## The previous _fix_start_room.gd rebuilt a 3-row-thick floor (y=207-209) across the FULL x=16-59
## span, but the zigzag diagonal's own leg1 path also crosses through that exact band at x=16-34
## (diagonal y = x+177, e.g. x=30->y207, x=27->y204, x=22->y199) - the thick floor there blocked the
## diagonal's own STANDING cell (one row above each step), breaking backward climbability right at
## the start-room boundary. Fix: floor only where it's safely clear of the diagonal (x>=35), and
## restore proper single-step + 3-row-headroom for the diagonal's own path through x=16-34.
const WALL := 13
var terr
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	# 1) clear the whole botched patch first
	for x in range(16, 60):
		for y in range(195, 210):
			terr.erase_cell(Vector2i(x, y))
	# 2) normal floor, safely right of the diagonal's path at this height (x>=35)
	for x in range(35, 60):
		terr.set_cell(Vector2i(x, 207), 0, Vector2i(WALL, 0))
		terr.set_cell(Vector2i(x, 208), 0, Vector2i(WALL, 0))
		terr.set_cell(Vector2i(x, 209), 0, Vector2i(WALL, 0))
	# 3) restore the diagonal's own steps through x=16-34 (leg1: y = x+177), 1 step + 3-row headroom
	for x in range(16, 35):
		var y: int = x + 177
		terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))
		terr.erase_cell(Vector2i(x, y - 1))
		terr.erase_cell(Vector2i(x, y - 2))
		terr.erase_cell(Vector2i(x, y - 3))
	print("fixed start-room floor / diagonal overlap, saved next")
	# 4) re-place the BLOKZ pillar (untouched by this range but make sure — y200-205 < 207 so it's fine,
	#    just re-assert in case an earlier pass clipped it)
	for y in range(200, 205):
		terr.set_cell(Vector2i(28, y), 0, Vector2i(67, 0))
	terr.set_cell(Vector2i(29, 205), 0, Vector2i(68, 0))
	terr.set_cell(Vector2i(30, 205), 0, Vector2i(68, 0))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
