extends SceneTree
## Level10.tscn = "1-10" (menu "LEVEL G"): HOVER JETS showcase. Grab the power-up, then hold Jump in
## the air to float down slowly and glide across wide chasms + up to high ledges.
## Run: Godot --headless --path . -s tools/build_level10.gd

const G := 0
const ST := 18
const GL := 19

var terrain: TileMapLayer
var markers: TileMapLayer
var powerups: TileMapLayer
var enemyt: TileMapLayer
var coint: TileMapLayer
var lvl: Node2D

func t(x, y, a): terrain.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func mk(x, y, a): markers.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func pw(x, y, a): powerups.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func solid(x0, x1, y0, y1, a=G):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, a)
func plat(x0, x1, row): solid(x0, x1, row, row + 1)      # a floating platform (2 tall)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func _save(nm, x, y):
	var s := Area2D.new(); s.name = nm; s.set_script(load("res://savestation.gd"))
	s.position = Vector2(x * 16 + 8, y * 16 + 8); lvl.add_child(s); s.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level10"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	markers = TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	powerups = TileMapLayer.new(); powerups.name = "Powerups"; powerups.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(powerups)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== S1 START + HOVER power-up + save =====
	solid(0, 14, 13, 14, G)
	mk(2, 12, ST)
	_save("Save1", 6, 12)
	pw(9, 11, 58)                          # HOVER JETS tile
	coin(11, 11); coin(12, 11)

	# ===== S2 WIDE CHASMS — hold Jump to float across (too far for a normal jump) =====
	plat(20, 24, 13)                       # island 1 (gap 15..19 = 5 wide)
	plat(31, 35, 13)                       # island 2 (gap 25..30 = 6 wide -> needs hover)
	plat(42, 46, 13)                       # island 3 (gap 36..41 = 6 wide)
	coin(22, 11); coin(33, 11); coin(44, 11)
	_save("Save2", 44, 11)

	# ===== S3 HOVER UP to a HIGH ledge, then float down to the goal =====
	plat(52, 58, 8)                        # a high ledge (hover extends the jump up to reach it)
	solid(52, 52, 8, 14)                   # a wall on its left so you can't just run up
	coin(55, 6)
	solid(64, 78, 13, 14, G)               # final ground (float down onto it from the high ledge)
	mk(74, 12, GL)                         # GOAL
	coin(70, 11); coin(71, 11)

	for n in [terrain, markers, powerups, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	print("saved Level10.tscn err=", ResourceSaver.save(packed, "res://Level10.tscn"))
	quit()
