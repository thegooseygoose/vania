extends SceneTree
## Builds Level30.tscn = "ENEMIES": a showcase level with one enemy type per room, plus an
## "armory" room at the start with every ability power-up so you can test any attack against
## any enemy. Menu: EXTRAS -> ENEMIES.
## Run: Godot --headless --path . -s tools/build_level_enemies.gd

const G := 0        # plain ground/wall tile (Terrain, tiles.tileset.tres)
const CEIL_Y := 1   # ceiling row (solid)
const FLOOR_Y := 14 # floor row (solid); rows 2..13 are the open interior
const WALL_TOP := 2
const WALL_BOT := 10   # walls run rows WALL_TOP..WALL_BOT, leaving 11..13 open as a walk-through gap

# Every ability power-up tile atlas code (Powerups layer), in pickup order.
const POWERUPS := [48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 65, 66, 81, 82]
# [enemy atlas code on EnemyTiles, room width in tiles, label for the comment]
const ROOMS := [
	[24, 20, "zoomer"],
	[25, 20, "serp"],
	[31, 20, "virus"],
	[29, 20, "bug"],
	[35, 20, "turret"],
	[36, 20, "urchin"],
	[23, 20, "gord"],
	[30, 34, "metroid boss"],
]
const ARMORY_W := 52
const WALL_W := 3

func _initialize(): call_deferred("_run")
func _run() -> void:
	var lvl := Node2D.new(); lvl.name = "LevelEnemies"
	var terrain := TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	var markers := TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	var enemyt := TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); lvl.add_child(enemyt)
	var coint := TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# total width: armory + (wall + room) per room + trailing wall + a short goal platform
	var total_w := ARMORY_W
	for r in ROOMS: total_w += WALL_W + int(r[1])
	total_w += WALL_W + 10

	# floor + ceiling run the full length
	for x in range(0, total_w):
		terrain.set_cell(Vector2i(x, FLOOR_Y), 0, Vector2i(G, 0))
		terrain.set_cell(Vector2i(x, FLOOR_Y + 1), 0, Vector2i(G, 0))
		terrain.set_cell(Vector2i(x, CEIL_Y), 0, Vector2i(G, 0))
		terrain.set_cell(Vector2i(x, CEIL_Y - 1), 0, Vector2i(G, 0))

	# player start, at the very beginning of the armory
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, FLOOR_Y * 16)
	spawns.add_child(ps)

	# a save station right at spawn so death (from testing an enemy) respawns you here instantly
	var SaveStationScript = load("res://savestation.gd")
	var save = SaveStationScript.new()
	save.name = "SaveStation"
	save.position = Vector2(5 * 16 + 8, FLOOR_Y * 16 - 4)
	lvl.add_child(save)

	# ARMORY: every ability power-up laid out along the floor
	var ax := 9
	for pcode in POWERUPS:
		pw.set_cell(Vector2i(ax, FLOOR_Y - 1), 0, Vector2i(pcode, 0))
		ax += 3

	var x := ARMORY_W
	for r in ROOMS:
		var ecode: int = r[0]
		var w: int = r[1]
		var label: String = r[2]
		# divider wall before this room (open gap at rows 11-13 to walk through)
		for wx in range(x, x + WALL_W):
			for wy in range(WALL_TOP, WALL_BOT + 1):
				terrain.set_cell(Vector2i(wx, wy), 0, Vector2i(G, 0))
		x += WALL_W
		var mid := x + int(w / 2.0)
		match label:
			"turret":
				# ceiling-mounted: paint just below the ceiling
				enemyt.set_cell(Vector2i(mid, CEIL_Y + 1), 0, Vector2i(ecode, 0))
			"urchin", "metroid boss":
				# floats in open air: paint mid-room, well clear of floor/ceiling
				enemyt.set_cell(Vector2i(mid, 7), 0, Vector2i(ecode, 0))
			_:
				# ground enemy: paint on the floor
				enemyt.set_cell(Vector2i(mid, FLOOR_Y - 1), 0, Vector2i(ecode, 0))
		x += w
		print("room '%s' at x=%d..%d, enemy@%d" % [label, x - w, x, mid])

	# trailing wall + goal platform
	for wx in range(x, x + WALL_W):
		for wy in range(WALL_TOP, WALL_BOT + 1):
			terrain.set_cell(Vector2i(wx, wy), 0, Vector2i(G, 0))
	x += WALL_W
	markers.set_cell(Vector2i(x + 4, FLOOR_Y - 1), 0, Vector2i(19, 0))  # GOAL star

	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co, save]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level30.tscn")
	print("total width=%d saved Level30.tscn err=%d" % [total_w, err])
	quit()
