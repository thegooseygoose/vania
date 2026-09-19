extends SceneTree
## Places a small visible cluster of the 2 new BLOKZ tiles (atlas 67 plain / 68 breakable) into
## Level29's Terrain right next to the player start (40,206), so the user actually sees/can test them
## in-game (2026-09-11 follow-up — they'd only been added to tiles.png/tileset, never painted anywhere).
## Re-skins existing SOLID wall cells only (same collision, just a different texture/behaviour) —
## no new passages, no new content, just makes the 2 tiles visibly present and testable.
const NORMAL := 67
const BREAKABLE := 68
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	# these cells are part of the existing solid pillar just left of spawn (40,206) — see
	# tools/_dump_start.gd output: solid block at x=28-31, y=199-205.
	for y in range(200, 205):
		terr.set_cell(Vector2i(28, y), 0, Vector2i(NORMAL, 0))
	terr.set_cell(Vector2i(29, 205), 0, Vector2i(BREAKABLE, 0))
	terr.set_cell(Vector2i(30, 205), 0, Vector2i(BREAKABLE, 0))
	_reown(scn, scn)
	var packed := PackedScene.new(); packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("placed BLOKZ tiles near spawn, saved err=%d" % err)
	quit()
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
