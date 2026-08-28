extends SceneTree
## Builds Level3.tscn = "1-3": a LONGER gauntlet that uses ALL 7 power-ups, built on the SAME
## proven single-ground-floor structure as 1-2 (so it's actually beatable) — every vertical gate
## returns to the main floor. Order: double-jump, ground-pound, wall-jump, morph, grapple, boomerang,
## then the GRAVITY SUIT + a water double-jump climb, then the GOAL.
## Run: Godot --headless --path . -s tools/build_level3.gd

const G := 0     # ground / solid
const B := 1     # brick (ground-poundable)
const LT := 28   # lava top
const LV := 29   # lava body
const WT := 45   # water surface
const WB := 46   # water body
const SW := 16   # door switch tile
const DR := 17   # door tile
const ST := 18   # start tile
const GL := 19   # goal tile

var terrain: TileMapLayer
var enemyt: TileMapLayer
var coint: TileMapLayer
var lvl: Node2D

func t(x, y, a): terrain.set_cell(Vector2i(x, y), 0, Vector2i(a, 0))
func solid(x0, x1, y0, y1, a=G):
	for x in range(x0, x1 + 1):
		for y in range(y0, y1 + 1):
			t(x, y, a)
func ground(x0, x1): solid(x0, x1, 13, 14, G)         # main floor rows (13-14), stand on row 12
func lava(x0, x1):
	for x in range(x0, x1 + 1):
		t(x, 13, LT); t(x, 14, LV); t(x, 15, LV)
func water(x0, x1, y0, y1):                            # fill a water box; top row gets the surface crest
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
	g.position = Vector2(x * 16 + 8, y * 16 + 8)
	lvl.add_child(g); g.owner = lvl

func _initialize(): call_deferred("_run")
func _run() -> void:
	lvl = Node2D.new(); lvl.name = "Level3"
	terrain = TileMapLayer.new(); terrain.name = "Terrain"; terrain.tile_set = load("res://tiles.tileset.tres"); lvl.add_child(terrain)
	enemyt = TileMapLayer.new(); enemyt.name = "EnemyTiles"; enemyt.tile_set = load("res://enemy_tiles.tileset.tres"); enemyt.visible = false; lvl.add_child(enemyt)
	coint = TileMapLayer.new(); coint.name = "CoinTiles"; coint.tile_set = load("res://coin_tiles.tileset.tres"); coint.visible = false; lvl.add_child(coint)
	var spawns := Node2D.new(); spawns.name = "Spawns"; lvl.add_child(spawns)
	var ps := Marker2D.new(); ps.name = "PlayerStart"; ps.position = Vector2(2 * 16 + 8, 13 * 16); spawns.add_child(ps)
	var en := Node2D.new(); en.name = "Enemies"; spawns.add_child(en)
	var co := Node2D.new(); co.name = "Coins"; spawns.add_child(co)

	# ===== S1 START + DOUBLE JUMP (x0..20) =====
	ground(0, 20)
	t(2, 12, ST)
	_pow("PowSquare", "square", 5, 11)
	coin(8, 11); coin(9, 11); coin(10, 11)
	solid(15, 15, 7, 12)                      # DJ GATE: 1-wide pillar, top row 7 → double-jump over it
	coin(15, 5)
	goomba(12, 12)

	# ===== S2 GROUND POUND (x20..38) — pound the brick, tunnel UNDER the wall =====
	ground(20, 25)
	_pow("PowTriangle", "triangle", 22, 11)
	solid(22, 30, 6, 6)                       # low ceiling (can't hop the wall)
	solid(26, 29, 13, 14, B)                  # BRICK floor — pound through it
	solid(0, 38, 17, 17)                      # bedrock under the tunnel
	solid(31, 31, 6, 14)                      # the wall you go UNDER
	terrain.erase_cell(Vector2i(31, 15)); terrain.erase_cell(Vector2i(31, 16))
	ground(32, 46)                            # surface resumes past the wall
	coin(27, 15); coin(28, 15)

	# ===== S3 WALL JUMP (x38..52) — climb the shaft, exit at the top-floor =====
	_pow("PowDiamond", "diamond", 40, 11)
	solid(46, 46, 0, 12)                      # left shaft wall (tall)
	solid(50, 50, 5, 12)                      # right shaft wall (short — open rows 0..4)
	solid(50, 64, 4, 4)                       # top exit floor (row 4) → stand at row 3
	coin(48, 8); coin(48, 4)

	# ===== S4 MORPH BALL (x52..64) — squeeze the 1-tile tunnel, drop back to ground =====
	_pow("PowCircle", "circle", 52, 3)
	solid(50, 57, 1, 1)                       # approach headroom (rows 2..3)
	solid(58, 63, 0, 2)                       # squeeze: ceiling to row 2 → only row 3 open
	coin(60, 3); coin(62, 3)
	solid(64, 70, 12, 14)                     # ledge/steps back down to ground level

	# ===== S5 GRAPPLE (x64..84) — swing the lava gap =====
	ground(64, 72)
	_pow("PowStar", "star", 66, 11)
	lava(73, 81)                              # wide lava gap
	_grab(77, 5)                              # grab point over the middle
	ground(82, 100)
	goomba(70, 12)

	# ===== S6 BOOMERANG + DOOR (x84..100) =====
	_pow("PowBoomerang", "boomerang", 86, 12)
	solid(93, 93, 9, 12, DR)                  # DOOR blocking the path
	t(98, 12, SW)                             # SWITCH beyond it — throw the boomerang through
	coin(95, 12); coin(96, 12)

	# ===== S7 GRAVITY SUIT + WATER climb (x100..126) =====
	ground(100, 126)                          # ground runs UNDER the whole finale (never soft-locks:
	_pow("PowWaterwalk", "waterwalk", 102, 11) # if you can't climb, you just walk back out on the ground)
	coin(105, 11); coin(106, 11)
	goomba(108, 12)
	# WATER GATE: a water column standing on the ground with ledges rising to the goal. In water your
	# jump is tiny (can't reach the 3-tile-high ledges) UNLESS you wear the suit, which restores a full
	# jump — so the suit is required to climb out. No side walls, so failing = drop back to the ground.
	water(112, 118, 4, 12)                    # water column above the ground
	solid(113, 115, 10, 10)                   # ledge 1 (3 tiles above the ground)
	solid(116, 118, 7, 7)                     # ledge 2 (3 up)
	coin(114, 8); coin(117, 5)
	# ===== S8 GOAL (x112..126) — the shelf at the top of the water climb =====
	solid(112, 126, 4, 4)                     # goal shelf (reachable from ledge 2, 3 tiles up)
	t(118, 3, GL)                             # GOAL star
	coin(121, 3)

	for n in [terrain, enemyt, coint, spawns, ps, en, co]:
		n.owner = lvl
	var packed := PackedScene.new()
	packed.pack(lvl)
	var err := ResourceSaver.save(packed, "res://Level3.tscn")
	print("saved Level3.tscn err=", err)
	quit()
