extends SceneTree
## Builds Level29.tscn = "BRINSTAR" from tools/brinstar_map.txt (auto-generated from the NES map
## by the classifier). 'W' = solid Brinstar block (nshappe), '.' = open. Places the player start,
## the Morph Ball, and a few zoomers automatically. Free-camera level (scrolls the whole region).
## Run: Godot --headless --path . -s tools/build_brinstar.gd   (then re-import)

const WALL := 13     # nshappe = Brinstar blue block
const MORPH := 48
const ZOOM := 24

func _read_map() -> Array:
	var f := FileAccess.open("res://tools/world_map.txt", FileAccess.READ)
	var rows: Array = []
	while not f.eof_reached():
		var ln := f.get_line()
		if ln.length() > 0:
			rows.append(ln)
	return rows

func _solid(rows: Array, x: int, y: int) -> bool:
	return y >= 0 and y < rows.size() and x >= 0 and x < rows[y].length() and rows[y][x] == "W"

func _initialize(): call_deferred("_run")
func _run() -> void:
	var rows := _read_map()
	var gh := rows.size()
	var gw: int = rows[0].length()
	var lvl := Node2D.new(); lvl.name = "Brinstar"
	var terrain := TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	var markers := TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	var enemyt := TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); lvl.add_child(enemyt)
	var coint := TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# paint terrain
	for y in gh:
		var row: String = rows[y]
		for x in row.length():
			if row[x] == "W":
				terrain.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))

	# player start: the NES start room is screen c2,r1 -> tile window cols 32..64, rows 15..45.
	# find an OPEN cell there with a floor beneath and headroom above.
	var startc := Vector2i(36, 18)
	var found := false
	for y in range(15, min(48, gh - 1)):
		for x in range(32, min(64, gw - 1)):
			if not _solid(rows, x, y) and not _solid(rows, x, y - 1) and _solid(rows, x, y + 1):
				startc = Vector2i(x, y); found = true; break
		if found: break
	ps.position = Vector2(startc.x * 16 + 8, (startc.y + 1) * 16)

	# scatter zoomers on floors across the whole world (they only wake near the camera)
	var placed := 0
	var want := 40
	for y in range(2, gh - 1):
		for x in range(2, gw - 1):
			if placed >= want: break
			if not _solid(rows, x, y) and _solid(rows, x, y + 1) and (x * 7 + y * 13) % 211 == 0 and Vector2i(x, y) != startc:
				enemyt.set_cell(Vector2i(x, y), 0, Vector2i(ZOOM, 0)); placed += 1
		if placed >= want: break

	# morph ball: nearest open floor cell to the start (search outward both ways on the start row),
	# so the world is traversable from the get-go; fall back to the start cell itself.
	var mb := startc
	for dx in [2, 3, 4, -2, -3, 5, -4, 6]:
		var x: int = startc.x + dx
		if x < 1 or x >= gw - 1: continue
		if not _solid(rows, x, startc.y) and _solid(rows, x, startc.y + 1):
			mb = Vector2i(x, startc.y); break
	pw.set_cell(mb, 0, Vector2i(MORPH, 0))

	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved Level29.tscn err=%d  %dx%d tiles, start=%s zoomers=%d morph=%s" % [err, gw, gh, str(startc), placed, str(mb)])
	quit()
