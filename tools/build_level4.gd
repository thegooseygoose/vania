extends SceneTree
## Builds Level4.tscn = "1-4": a LONGER metroidvania-flavored world. Reuses 1-3's PROVEN, beatable
## gate dimensions (double-jump, ground-pound, wall-jump, morph, grapple, boomerang, gravity-suit),
## chained with a continuous safety floor (no soft-locks), then a VERTICAL TOWER finale you climb to
## a high goal. THREE SaveStations let you resume with your abilities on death.
## Specials (start/goal/switch/door) paint on a MARKERS layer (their tiles were removed from Terrain).
## Run: Godot --headless --path . -s tools/build_level4.gd

const G := 0
const B := 1
const LT := 28
const LV := 29
const WT := 45
const WB := 46
const HK := 47   # hook tile (grapple anchor, stays on Terrain)
const SW := 16
const DR := 17
const ST := 18
const GL := 19

var terrain: TileMapLayer
var markers: TileMapLayer
var enemyt: TileMapLayer
var coint: TileMapLayer
var lvl: Node2D

func t(x, y, a): terrain.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func mk(x, y, a): markers.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func solid(x0, x1, y0, y1, a=G):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, a)
func ground(x0, x1): solid(x0, x1, 13, 14, G)
func lava(x0, x1):
	for x in range(x0, x1 + 1):
		t(x, 13, LT); t(x, 14, LV); t(x, 15, LV)
func water(x0, x1, y0, y1):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, WT if y == y0 else WB)
func coin(x, y): coint.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))
func goomba(x, y): enemyt.set_cell(Vector2i(x, y), 0, Vector2i(0, 0))

func _pow(nm, shape, x, y):
	var p := Area2D.new(); p.name = nm; p.set_script(load("res://powerup.gd"))
	p.set("shape", shape); p.position = Vector2(x * 16 + 8, y * 16 + 8)
	lvl.add_child(p); p.owner = lvl
func _grab(x, y):
	var g := Node2D.new(); g.name = "GrabPoint"; g.set_script(load("res://grabpoint.gd"))
	g.position = Vector2(x * 16 + 8, y * 16 + 8); lvl.add_child(g); g.owner = lvl
func _save(nm, x, y):
	var s := Area2D.new(); s.name = nm; s.set_script(load("res://savestation.gd"))
	s.position = Vector2(x * 16 + 8, y * 16 + 8); lvl.add_child(s); s.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level4"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	markers = TileMapLayer.new(); markers.name = "Markers"; markers.tile_set = load("res://tiles_markers.tileset.tres"); lvl.add_child(markers)
	var pw := TileMapLayer.new(); pw.name = "Powerups"; pw.tile_set = load("res://tiles_powerups.tileset.tres"); lvl.add_child(pw)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== S1 START + SAVE 1 + DOUBLE JUMP (x0..20) =====
	ground(0, 20)
	mk(2, 12, ST)
	_save("Save1", 8, 12)
	_pow("PowSquare", "square", 5, 11)
	coin(11, 11); coin(12, 11); coin(13, 11)
	solid(16, 16, 7, 12)                       # DJ gate: 1-wide pillar, top row 7
	coin(16, 5)

	# ===== S2 GROUND POUND (x20..46) =====
	ground(20, 25)
	_pow("PowTriangle", "triangle", 22, 11)
	solid(22, 30, 6, 6)                        # low ceiling (can't hop the wall)
	solid(26, 29, 13, 14, B)                   # brick floor — pound through it
	solid(0, 46, 17, 17)                       # bedrock under the tunnel
	solid(31, 31, 6, 14)                       # wall you go UNDER
	terrain.erase_cell(Vector2i(31, 15)); terrain.erase_cell(Vector2i(31, 16))
	ground(32, 46)
	coin(27, 15); coin(28, 15)
	goomba(36, 12)

	# ===== S3 WALL JUMP (x46..64) — climb shaft to the top floor =====
	_pow("PowDiamond", "diamond", 40, 11)
	solid(46, 46, 0, 12)                       # left shaft wall (tall)
	solid(50, 50, 5, 12)                       # right shaft wall (short — rows 0..4 open)
	solid(50, 64, 4, 4)                        # top exit floor (row 4)
	coin(48, 8); coin(48, 4)

	# ===== S4 MORPH (x52..64 on the top floor) — squeeze, drop back down =====
	_pow("PowCircle", "circle", 52, 3)
	solid(50, 57, 1, 1)                        # approach headroom
	solid(58, 63, 0, 2)                        # squeeze: only row 3 open
	solid(64, 70, 12, 14)                      # steps back down to ground

	# ===== S5 SAVE 2 + GRAPPLE (x64..86) — swing the lava gap =====
	ground(64, 72)
	_save("Save2", 68, 12)
	_pow("PowStar", "star", 66, 11)
	lava(73, 81)
	_grab(77, 5)
	ground(82, 100)
	goomba(70, 12)

	# ===== S6 BOOMERANG + DOOR (x86..100) =====
	_pow("PowBoomerang", "boomerang", 86, 12)
	solid(93, 93, 9, 12, DR)                   # door blocking the path
	mk(98, 12, SW)                             # switch beyond it
	coin(95, 12); coin(96, 12)

	# ===== S7 GRAVITY SUIT + WATER climb (x100..126) =====
	ground(100, 128)
	_pow("PowWaterwalk", "waterwalk", 102, 11)
	coin(105, 11); coin(106, 11)
	goomba(110, 12)
	water(112, 118, 4, 12)
	solid(113, 115, 10, 10)                    # ledge 1
	solid(116, 118, 7, 7)                      # ledge 2
	solid(112, 128, 4, 4)                      # top shelf (reached from ledge 2)
	coin(114, 8); coin(117, 5)

	# ===== S8 SAVE 3 + VERTICAL TOWER FINALE (x128..150) — climb to a high goal =====
	# From the row-4 shelf, hop staggered ledges UP (double-jump/wall-jump, both owned by now).
	_save("Save3", 126, 3)
	solid(132, 134, 1, 1)                      # ledge up 3
	solid(137, 139, -2, -2)                    # ledge up 3
	solid(142, 144, -5, -5)                    # ledge up 3
	solid(146, 152, -8, -8)                    # goal shelf (up 3 from the last ledge)
	solid(145, 152, -13, -13)                  # ceiling above the goal (raises the level top so the
	solid(152, 152, -13, -8)                   #   free camera can scroll up and frame the player+goal)
	coin(133, 0); coin(138, -3); coin(143, -6)
	mk(149, -9, GL)                            # GOAL star at the top of the tower

	for n in [terrain, markers, pw, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level4.tscn")
	print("saved Level4.tscn err=", err)
	quit()
