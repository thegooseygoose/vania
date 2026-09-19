extends SceneTree
## Retires atlas75 (#0070EC) from the wall palette entirely -- it's suspiciously close to the real
## door's own rim color (per the door-extraction notes: normal doors are RGB(32,56,236)), so ANY
## large wall area using it risks reading as a fake door, not just fine-grained checker spots.
## Reassigns every atlas75 cell to its next-closest OTHER palette color.
const PALETTE := {
	70: Color8(0xBC,0xBC,0xBC), 71: Color8(0x00,0x90,0x38),
	72: Color8(0xC8,0x4C,0x0C), 73: Color8(0x74,0x74,0x74), 74: Color8(0x80,0x00,0xF0),
	76: Color8(0x00,0x80,0x88), 77: Color8(0xE4,0x00,0x58),
	78: Color8(0xBC,0x00,0xBC), 79: Color8(0x00,0x94,0x00), 80: Color8(0x00,0x00,0xA8),
}
const RETIRE := 69
const RETIRE_COLOR := Color8(0xD8,0x28,0x00)
func _initialize(): call_deferred("_run")
func _reown(node, root):
	for c in node.get_children():
		c.owner = root
		_reown(c, root)
func _run():
	var best_i := -1; var best_d := 1e9
	for k in PALETTE.keys():
		var p: Color = PALETTE[k]
		var d: float = (p.r-RETIRE_COLOR.r)*(p.r-RETIRE_COLOR.r) + (p.g-RETIRE_COLOR.g)*(p.g-RETIRE_COLOR.g) + (p.b-RETIRE_COLOR.b)*(p.b-RETIRE_COLOR.b)
		if d < best_d: best_d = d; best_i = k
	print("reassigning atlas75 -> atlas%d" % best_i)
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var n := 0
	for c in terr.get_used_cells():
		if terr.get_cell_atlas_coords(c).x == RETIRE:
			terr.set_cell(c, 0, Vector2i(best_i, 0))
			n += 1
	print("reassigned %d cells" % n)
	_reown(scn, scn)
	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("saved err=%d" % err)
	quit()
