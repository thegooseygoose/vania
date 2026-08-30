extends SceneTree
## Builds Level7.tscn = "1-7" (menu "LEVEL D"): a DASH-ATTACK showcase. Grab the dash power-up, then
## blast through brick walls and enemy lines and across a gap with it. Run:
##   Godot --headless --path . -s tools/build_level7.gd

const G := 0     # ground
const B := 1     # brick (dash/ground-pound breaks it)
const ST := 18   # start marker
const GL := 19   # goal star

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
func ground(x0, x1): solid(x0, x1, 13, 14, G)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func goomba(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func _save(nm, x, y):
	var s := Area2D.new(); s.name = nm; s.set_script(load("res://savestation.gd"))
	s.position = Vector2(x * 16 + 8, y * 16 + 8); lvl.add_child(s); s.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level7"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	markers = TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	powerups = TileMapLayer.new(); powerups.name = "Powerups"; powerups.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(powerups)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== S1 START + DASH power-up + save (x0..14) =====
	ground(0, 14)
	mk(2, 12, ST)
	_save("Save1", 6, 12)
	pw(9, 11, 55)                        # DASH power-up tile (touch to collect)
	coin(11, 11); coin(12, 11)

	# ===== S2 BRICK WALL — dash straight through it (x16..17) =====
	ground(14, 30)
	solid(16, 17, 10, 12, B)             # a brick wall blocking the path; dash smashes it
	coin(16, 8); coin(17, 8)

	# ===== S3 ENEMY LINE — dash to plough through them (x20..30) =====
	goomba(21, 12); goomba(24, 12); goomba(27, 12); goomba(30, 12)

	# ===== S4 THICK BRICK WALL — dash through at speed (x32..34) =====
	ground(32, 38)
	solid(32, 34, 10, 12, B)
	coin(33, 8)

	# ===== S5 DASH GAP — the dash carries you across (x40..42) =====
	ground(35, 39)
	# gap at x40..42 (no floor); ground resumes at 43
	ground(43, 60)
	coin(41, 12)

	# ===== S6 SAVE + FINAL WALL → GOAL (x44..60) =====
	_save("Save2", 45, 12)
	solid(50, 52, 10, 12, B)             # last brick wall before the goal
	mk(57, 12, GL)                       # GOAL star
	coin(55, 11); coin(56, 11)

	for n in [terrain, markers, powerups, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	print("saved Level7.tscn err=", ResourceSaver.save(packed, "res://Level7.tscn"))
	quit()
