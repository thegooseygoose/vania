extends SceneTree
## Loads the full-size Level29 (the whole map backdrop) and carves a CLEAN, beatable critical path
## through it: a descending snake of 3-tall corridors (with solid floors) + 2-wide drop shafts, plus
## a Morph Ball, a morph gate, a shootable door, enemies, and a GOAL. The rest of the map stays as
## backdrop. Saves back to Level29.tscn.
## Run: Godot --headless --path . -s tools/carve_path.gd

const WALL := 13
const MORPH := 48
const GOAL := 19
const ZOOM := 24
const BUG := 29
const DL := 26
const DM := 27
const DR := 28

var terr
# waypoints of the path (tile x,y). Segments alternate H and V; every V goes DOWN (no forced climbs).
const WP := [
	Vector2i(36, 18), Vector2i(200, 18),
	Vector2i(200, 120), Vector2i(440, 120),
	Vector2i(440, 300), Vector2i(60, 300),
	Vector2i(60, 420), Vector2i(240, 420),
]

func _open(x: int, y: int) -> void:
	terr.erase_cell(Vector2i(x, y))
func _solid(x: int, y: int) -> void:
	terr.set_cell(Vector2i(x, y), 0, Vector2i(WALL, 0))

# horizontal corridor at standing row fy: 3 tall open (fy, fy-1, fy-2) with a solid floor at fy+1
func carve_h(x0: int, x1: int, fy: int) -> void:
	var a: int = min(x0, x1); var b: int = max(x0, x1)
	for x in range(a, b + 1):
		_open(x, fy); _open(x, fy - 1); _open(x, fy - 2)
		_solid(x, fy + 1)

# vertical drop shaft at column x (2 wide: x, x+1), from y0 to y1
func carve_v(x: int, y0: int, y1: int) -> void:
	var a: int = min(y0, y1); var b: int = max(y0, y1)
	for y in range(a, b + 1):
		_open(x, y); _open(x + 1, y)
		_open(x - 1, y - 0)   # a touch of clearance on the near wall
	# leave floors at the very bottom (handled by the next H segment)

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()
	terr = scn.get_node("Terrain")
	var pw = scn.get_node("Powerups")
	var mk = scn.get_node("Markers")
	var et = scn.get_node("EnemyTiles")

	# carve all HORIZONTAL corridors first (they lay down floors) ...
	for i in range(0, WP.size() - 1):
		var p: Vector2i = WP[i]; var q: Vector2i = WP[i + 1]
		if p.y == q.y:
			carve_h(p.x, q.x, p.y)
	# ... then VERTICAL shafts (they punch the drop through the corridor floors)
	for i in range(0, WP.size() - 1):
		var p: Vector2i = WP[i]; var q: Vector2i = WP[i + 1]
		if p.x == q.x:
			carve_v(p.x, p.y, q.y)

	# MORPH GATE on the 2nd horizontal corridor (y=120): 1-tall squeeze at x=320
	var gate_x := 320; var gate_y := 120
	_solid(gate_x, gate_y - 1); _solid(gate_x, gate_y - 2)   # ceiling drops to 1 tall -> must morph
	_solid(gate_x, gate_y + 1)                                # keep its floor

	# player start on the first corridor
	var ps = scn.get_node("Spawns/PlayerStart")
	ps.position = Vector2(WP[0].x * 16 + 8, (WP[0].y + 1) * 16)

	# clear any stray markers (e.g. a leftover start-tile that would override our spawn)
	for c in mk.get_used_cells(): mk.erase_cell(c)
	# pickups / goal
	pw.set_cell(Vector2i(60, 18), 0, Vector2i(MORPH, 0))            # Morph Ball early on the top corridor
	mk.set_cell(Vector2i(WP[WP.size()-1].x, WP[WP.size()-1].y), 0, Vector2i(GOAL, 0))   # GOAL at the end

	# a shootable door on the y=300 corridor
	et.set_cell(Vector2i(250, 300), 0, Vector2i(DL, 0))
	et.set_cell(Vector2i(251, 300), 0, Vector2i(DM, 0))
	et.set_cell(Vector2i(252, 300), 0, Vector2i(DR, 0))

	# scatter enemies along each horizontal corridor (~every 34 tiles) so the long stretches aren't empty
	var recount := 0
	for i in range(0, WP.size() - 1):
		var p: Vector2i = WP[i]; var q: Vector2i = WP[i + 1]
		if p.y != q.y: continue
		var a: int = min(p.x, q.x); var b: int = max(p.x, q.x)
		var ex := a + 24
		while ex < b - 8:
			if abs(ex - gate_x) > 3 and (ex < 248 or ex > 254):   # keep clear of the morph gate + door
				var kind := ZOOM if recount % 2 == 0 else BUG
				et.set_cell(Vector2i(ex, p.y), 0, Vector2i(kind, 0))
				recount += 1
			ex += 34

	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("carved critical path, saved err=%d  start=%s goal=%s" % [err, str(WP[0]), str(WP[WP.size()-1])])
	quit()

func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
