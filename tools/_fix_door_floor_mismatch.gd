extends SceneTree
## Levels the approach floor on both sides of every door whose floor height differs from the
## door's own floor by 2+ tiles (71 of 196 doors, some off by as much as 8 tiles) — the real cause
## of the recurring "walks into the door forever, never clears it" freeze. Rather than relying on a
## physics hop (only good for 1-tile gaps), this directly raises/lowers a short strip of terrain on
## the mismatched side so it's flush with the door's own floor.
const WALL := 13
const W := 480; const H := 450
var solid := PackedByteArray()
func idx(x:int,y:int)->int: return y*W+x
func floor_row(x: int, y0: int) -> int:
	for y in range(y0, y0 + 12):
		if y < H and solid[idx(x, y)] == 1: return y
	return -1
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	solid.resize(W*H)
	for c in terr.get_used_cells():
		var ax: int = terr.get_cell_atlas_coords(c).x
		if c.x>=0 and c.x<W and c.y>=0 and c.y<H and (ax<45 or ax>=67): solid[idx(c.x,c.y)]=1
	var cellmap := {}
	for c in et.get_used_cells():
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax>=26 and ax<=28: cellmap[c] = ax
	var doorL := []
	for c in cellmap.keys():
		if cellmap[c] == 26: doorL.append(c)

	var fixed := 0
	for L in doorL:
		var door_floor: int = floor_row(L.x + 1, L.y)
		if door_floor < 0: continue
		for side in [-2, 4]:   # same check columns as the audit: left approach, right approach
			var cx: int = L.x + side
			var cur_floor: int = floor_row(cx, L.y)
			if cur_floor < 0: continue
			var diff: int = door_floor - cur_floor
			if absi(diff) < 2: continue
			# level a small 3-column strip (cx-1..cx+1) to the door's floor height
			# NOTE: fixed 2026-09-12 — this was backwards on the first attempt and broke
			# GOAL_REACHABLE by erasing legitimate floor. diff = door_floor - cur_floor:
			#   diff < 0  => door_floor < cur_floor => this side is a DEEPER PIT than the door
			#               => BUILD UP (fill door_floor..cur_floor-1) to raise it to match
			#   diff > 0  => door_floor > cur_floor => this side STICKS UP above the door
			#               => CARVE DOWN (erase cur_floor..door_floor-1) to lower it to match
			for xx in range(cx - 1, cx + 2):
				if diff < 0:
					for y in range(door_floor, cur_floor):
						terr.set_cell(Vector2i(xx, y), 0, Vector2i(WALL, 0))
				else:
					for y in range(cur_floor, door_floor):
						terr.erase_cell(Vector2i(xx, y))
						terr.erase_cell(Vector2i(xx, y - 1))
						terr.erase_cell(Vector2i(xx, y - 2))
			fixed += 1
	print("leveled the approach floor at %d door-sides" % fixed)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
