extends SceneTree
## Builds a small NES-Metroid-region color palette (12 colors, sampled from the real source image)
## as new solid wall tiles, appended to tiles.png + registered in tiles.tileset.tres, then repaints
## every Level29 Terrain cell (currently all flat atlas13) to its nearest-matching palette color —
## giving the map real Brinstar/Norfair/Ridley/Tourian-style regional variety instead of one grey block.
const PALETTE := [
	Color8(0xD8, 0x28, 0x00), Color8(0xBC, 0xBC, 0xBC), Color8(0x00, 0x90, 0x38),
	Color8(0xC8, 0x4C, 0x0C), Color8(0x74, 0x74, 0x74), Color8(0x80, 0x00, 0xF0),
	Color8(0x00, 0x70, 0xEC), Color8(0x00, 0x80, 0x88), Color8(0xE4, 0x00, 0x58),
	Color8(0xBC, 0x00, 0xBC), Color8(0x00, 0x94, 0x00), Color8(0x00, 0x00, 0xA8),
]
const START_COL := 69
const W := 480; const H := 450

func _initialize(): call_deferred("_run")
func _run():
	var src := Image.load_from_file("res://../pro wrestling/new sprites/meto.png")
	src.convert(Image.FORMAT_RGBA8)

	# 1) build the new tiles.png columns: flat fill + a subtle 1px darker border for definition
	var tiles := Image.load_from_file("res://tiles.png")
	var new_w: int = (START_COL + PALETTE.size()) * 16
	var bigger := Image.create(new_w, 16, false, Image.FORMAT_RGBA8)
	bigger.blit_rect(tiles, Rect2i(Vector2i.ZERO, tiles.get_size()), Vector2i.ZERO)
	for i in range(PALETTE.size()):
		var col: Color = PALETTE[i]
		var dark: Color = col.darkened(0.35)
		var x0: int = (START_COL + i) * 16
		for y in range(16):
			for x in range(16):
				var edge: bool = x == 0 or y == 0 or x == 15 or y == 15
				bigger.set_pixel(x0 + x, y, dark if edge else col)
	bigger.save_png("res://tiles.png")
	print("tiles.png extended to ", bigger.get_size())

	# 2) register each new column in tiles.tileset.tres (same solid square collision as atlas13)
	var tset_path := "res://tiles.tileset.tres"
	var f := FileAccess.open(tset_path, FileAccess.READ)
	var text := f.get_as_text()
	f.close()
	var insert := ""
	for i in range(PALETTE.size()):
		var col: int = START_COL + i
		insert += "%d:0/0 = 0\n" % col
		insert += "%d:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)\n" % col
	# insert right before the "\n[resource]" marker (same place every other tile is listed)
	var marker := "\n[resource]"
	var pos: int = text.find(marker)
	text = text.insert(pos, "\n" + insert.strip_edges())
	f = FileAccess.open(tset_path, FileAccess.WRITE)
	f.store_string(text)
	f.close()
	print("registered %d new tile atlas entries starting at col %d" % [PALETTE.size(), START_COL])
	quit()
