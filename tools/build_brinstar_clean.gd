extends SceneTree
## Hand-designed, guaranteed-playable Brinstar opening (Level29.tscn). Clean continuous floors,
## a real path: start corridor -> drop down the shaft -> Morph Ball -> 1-tile morph tunnel ->
## shootable door -> GOAL. Uses nshappe blue blocks + a zoomer + a bug. Run then re-import.
## Run: Godot --headless --path . -s tools/build_brinstar_clean.gd

const W := 44
const H := 24
const WALL := 13     # nshappe blue block
const MORPH := 48    # morph-ball powerup tile
const GOAL := 19     # goal marker tile
const ZOOM := 24
const BUG := 29
const DL := 26       # door left / mid / right (EnemyTiles)
const DM := 27
const DR := 28

func solid(x: int, y: int) -> bool:
	if x == 0 or x == W - 1 or y == 0 or y == H - 1: return true
	if y >= 8 and y <= 16:                 # upper floor (row8) + thick ground, with a 2-wide shaft
		return not (x == 20 or x == 21)
	if y == 20 or y == 21 or y == 22: return true   # lower floor + base
	if y >= 17 and y <= 19:                 # lower corridor (3 tall), with a morph-tunnel wall at col30
		return x == 30 and (y == 17 or y == 18)
	return false                            # rows 1-7 = open upper interior

func _initialize(): call_deferred("_run")
func _run() -> void:
	var lvl := Node2D.new(); lvl.name = "Brinstar"
	var terrain := TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	var markers := TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	var enemyt := TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); lvl.add_child(enemyt)
	var coint := TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 8 * 16); spawns.add_child(ps)  # feet on upper floor row8
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	for y in H:
		for x in W:
			if solid(x, y):
				terrain.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))
	# power-up + goal + enemies (row indices: upper stand=7, lower stand=19)
	pw.set_cell(Vector2i(16, 19), 0, Vector2i(MORPH, 0))          # morph ball (lower corridor, left of shaft)
	markers.set_cell(Vector2i(41, 19), 0, Vector2i(GOAL, 0))      # GOAL at the far right
	enemyt.set_cell(Vector2i(10, 7), 0, Vector2i(ZOOM, 0))        # zoomer on the upper corridor
	enemyt.set_cell(Vector2i(34, 19), 0, Vector2i(BUG, 0))        # bug after the morph tunnel
	enemyt.set_cell(Vector2i(37, 19), 0, Vector2i(DL, 0))         # door (blocks the 3-tall corridor)
	enemyt.set_cell(Vector2i(38, 19), 0, Vector2i(DM, 0))
	enemyt.set_cell(Vector2i(39, 19), 0, Vector2i(DR, 0))

	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new(); packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved clean Brinstar Level29.tscn err=%d (%dx%d)" % [err, W, H])
	quit()
