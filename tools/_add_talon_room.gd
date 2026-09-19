extends SceneTree
## Non-destructive append: extends Level30.tscn's corridor past the existing end (terrain
## max_x=312, old goal at 307,13) with a new divider wall + a wide room for the new TALON
## (flying dive-bomb boss, EnemyTiles atlas 38), then moves the goal marker to the new end.
## Does NOT touch any existing cell before x=313.
const G := 0
const CEIL_Y := 1
const FLOOR_Y := 14
const WALL_TOP := 2
const WALL_BOT := 10
const WALL_W := 3
const ROOM_W := 36
const TALON_ATLAS := 38
const OLD_MAX_X := 312
const OLD_GOAL := Vector2i(307, 13)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level30.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var mk = scn.get_node("Markers")
	var et = scn.get_node("EnemyTiles")

	# sanity: confirm nothing unexpected has moved since we last inspected this file
	assert(mk.get_cell_atlas_coords(OLD_GOAL).x == 19, "old goal marker not where expected")

	mk.erase_cell(OLD_GOAL)   # goal moves to the new end

	var x := OLD_MAX_X + 1
	# divider wall
	for wx in range(x, x + WALL_W):
		for wy in range(WALL_TOP, WALL_BOT + 1):
			terr.set_cell(Vector2i(wx, wy), 0, Vector2i(G, 0))
	# floor/ceiling continue under/over the wall too
	for wx in range(x, x + WALL_W):
		terr.set_cell(Vector2i(wx, FLOOR_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, FLOOR_Y + 1), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, CEIL_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, CEIL_Y - 1), 0, Vector2i(G, 0))
	x += WALL_W

	# TALON room: floor/ceiling only (open interior, no side walls needed -- divider wall behind,
	# trailing wall ahead)
	var room_start := x
	for rx in range(x, x + ROOM_W):
		terr.set_cell(Vector2i(rx, FLOOR_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(rx, FLOOR_Y + 1), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(rx, CEIL_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(rx, CEIL_Y - 1), 0, Vector2i(G, 0))
	var mid := room_start + int(ROOM_W / 2.0)
	et.set_cell(Vector2i(mid, 6), 0, Vector2i(TALON_ATLAS, 0))   # floats mid-air, like metroid/urchin
	x += ROOM_W
	print("TALON room at x=%d..%d, enemy@%d" % [room_start, x, mid])

	# trailing wall + goal platform (same shape as the original tail)
	for wx in range(x, x + WALL_W):
		for wy in range(WALL_TOP, WALL_BOT + 1):
			terr.set_cell(Vector2i(wx, wy), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, FLOOR_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, FLOOR_Y + 1), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, CEIL_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(wx, CEIL_Y - 1), 0, Vector2i(G, 0))
	x += WALL_W
	for px in range(x, x + 10):
		terr.set_cell(Vector2i(px, FLOOR_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(px, FLOOR_Y + 1), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(px, CEIL_Y), 0, Vector2i(G, 0))
		terr.set_cell(Vector2i(px, CEIL_Y - 1), 0, Vector2i(G, 0))
	mk.set_cell(Vector2i(x + 4, FLOOR_Y - 1), 0, Vector2i(19, 0))
	print("new goal at x=%d" % (x + 4))

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
