extends SceneTree
## Level11.tscn = "1-11" (menu "LEVEL H"): a proper showcase of the new powers with real set-pieces —
## DASH gauntlet, RIDER-KICK dive arena, OVERCLOCK platform-hop over a pit, and a HOVER chasm climb.
## Verticality + spacing so each power gets its own moment. Run: Godot --headless -s tools/build_level11.gd

const G := 0
const B := 1
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
func ground(x0, x1): solid(x0, x1, 13, 14, G)
func plat(x0, x1, row): solid(x0, x1, row, row + 1)
func stair(x, top):                     # a 1-wide step column from `top` down to the floor
	solid(x, x, top, 12)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func goomba(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func _save(nm, x, y):
	var s := Area2D.new(); s.name = nm; s.set_script(load("res://savestation.gd"))
	s.position = Vector2(x * 16 + 8, y * 16 + 8); lvl.add_child(s); s.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level11"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	markers = TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	powerups = TileMapLayer.new(); powerups.name = "Powerups"; powerups.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(powerups)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== S1 START — collect all 4 powers on a little pedestal + save =====
	ground(0, 16)
	mk(2, 12, ST)
	_save("Save1", 5, 12)
	plat(8, 15, 11)                       # pedestal you hop onto
	pw(9, 10, 55)    # DASH
	pw(11, 10, 56)   # RIDER KICK
	pw(13, 10, 57)   # OVERCLOCK
	pw(15, 10, 58)   # HOVER
	coin(9, 8); coin(11, 8); coin(13, 8); coin(15, 8)

	# ===== S2 DASH GAUNTLET — blast a line of brick walls + goombas (F / LB) =====
	ground(16, 34)
	solid(20, 20, 7, 12, B); goomba(22, 12)
	solid(24, 24, 7, 12, B); goomba(26, 12)
	solid(28, 28, 7, 12, B)
	solid(16, 34, 6, 6)                   # roof: full-height brick walls under it → dash is the only way through
	coin(21, 11); coin(25, 11); coin(29, 11); coin(31, 11)

	# ===== S3 RIDER-KICK ARENA — leap the tower, dive-kick a goomba row, bounce to the far ledge =====
	solid(36, 40, 8, 12)                  # a tower to climb + leap from (stairs on its left)
	stair(35, 11); stair(36, 10)
	coin(38, 5)
	# drop zone: a row of goombas on the ground to dive-kick along (bounce-chain)
	ground(34, 56)
	goomba(44, 12); goomba(46, 12); goomba(48, 12); goomba(50, 12)
	solid(53, 55, 9, 12, B)               # a brick wall past them — dive-kick or dash through
	coin(45, 10); coin(47, 10); coin(49, 10)

	# ===== S4 OVERCLOCK — hop enemy-topped pillars over a PIT (slow time: T / L3) =====
	# pit from x57..71 (no floor); small pillars each with a patrolling goomba
	_save("Save2", 55, 12)
	solid(59, 60, 11, 12); goomba(59, 10)
	solid(63, 64, 11, 12); goomba(63, 10)
	solid(67, 68, 11, 12); goomba(67, 10)
	coin(61, 9); coin(65, 9)
	ground(72, 80)                        # safe landing past the pit

	# ===== S5 HOVER CLIMB — float across wide gaps and UP rising islands to a high goal (hold Jump) =====
	_save("Save3", 77, 12)                # save before the chasm (a missed hover = respawn here)
	plat(86, 88, 12)                      # island 1 (gap 81..85 = 5 wide → needs hover)
	plat(94, 96, 10)                      # island 2, higher (gap 89..93)
	plat(102, 108, 7)                     # goal shelf, higher still (gap 97..101)
	coin(84, 10); coin(92, 8); coin(100, 5)
	mk(105, 6, GL)                        # GOAL on the top shelf

	for n in [terrain, markers, powerups, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	print("saved Level11.tscn err=", ResourceSaver.save(packed, "res://Level11.tscn"))
	quit()
