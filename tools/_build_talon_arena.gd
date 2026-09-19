extends SceneTree
## Extends Level29/Brinstar into the fresh space opened by the width bump (520->580): opens the
## BROOD arena's old sealed end wall (x516-519), then builds a new TALL arena (x520-579) for
## TALON, floor continuous with BROOD's room (y409/410), ceiling ramping up from y386 to y360 for
## real dive room, sealed by a new end wall at x576-579. Same "extend into fresh space" approach
## used for BROOD's own arena (see vania-brood-boss memory) -- doesn't touch any existing terrain
## before x516.
const WALL := 13
const FLOOR_Y := 409
const OLD_CEIL_Y := 386
const NEW_CEIL_Y := 360
const ARENA_END := 575   # last open column; end wall starts at 576
var terr

func _solid_col(x: int, y0: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))

func _clear_col(x: int, y0: int, y1: int) -> void:
	for y in range(y0, y1 + 1):
		terr.erase_cell(Vector2i(x, y))

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")

	# open the old BROOD-arena end wall (x516-519, y388-408) -- the interior band between its
	# floor (409/410) and ceiling (386/387)
	for x in range(516, 520):
		_clear_col(x, 388, 408)

	# new arena x520-575: floor continuous at 409/410; ceiling ramps from 386 up to 360 over
	# x520-535, then holds at 360 for the rest (tall dive room)
	for x in range(520, ARENA_END + 1):
		terr.set_cell(Vector2i(x, FLOOR_Y), 0, Vector2i(WALL, 0))
		terr.set_cell(Vector2i(x, FLOOR_Y + 1), 0, Vector2i(WALL, 0))
		var ceil_y: int = OLD_CEIL_Y
		if x >= 535:
			ceil_y = NEW_CEIL_Y
		elif x > 520:
			# linear ramp between 520 (386) and 535 (360)
			var t: float = float(x - 520) / 15.0
			ceil_y = int(round(lerp(float(OLD_CEIL_Y), float(NEW_CEIL_Y), t)))
		terr.set_cell(Vector2i(x, ceil_y), 0, Vector2i(WALL, 0))
		terr.set_cell(Vector2i(x, ceil_y - 1), 0, Vector2i(WALL, 0))
		# clear the interior between ceiling and floor (in case of leftover void-default solids)
		_clear_col(x, ceil_y + 1, FLOOR_Y - 1)

	# end wall, full height of the tall section
	for x in range(ARENA_END + 1, ARENA_END + 5):
		_solid_col(x, NEW_CEIL_Y - 1, FLOOR_Y + 1)

	# TALON enemy tile, floating mid-air in the tall section
	var et = scn.get_node("EnemyTiles")
	et.set_cell(Vector2i(550, 390), 0, Vector2i(38, 0))

	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("built TALON arena x520-%d (ceil ramps 386->360 by x535), TALON@(550,390), saved err=%d" % [ARENA_END + 4, err])
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
