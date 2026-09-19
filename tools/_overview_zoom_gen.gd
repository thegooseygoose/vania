extends SceneTree
const PALETTE := {
	69: Color8(0xD8,0x28,0x00), 70: Color8(0xBC,0xBC,0xBC), 71: Color8(0x00,0x90,0x38),
	72: Color8(0xC8,0x4C,0x0C), 73: Color8(0x74,0x74,0x74), 74: Color8(0x80,0x00,0xF0),
	75: Color8(0x00,0x70,0xEC), 76: Color8(0x00,0x80,0x88), 77: Color8(0xE4,0x00,0x58),
	78: Color8(0xBC,0x00,0xBC), 79: Color8(0x00,0x94,0x00), 80: Color8(0x00,0x00,0xA8),
}
## Usage: -s tools/_overview_zoom_gen.gd -- x0 x1 y0 y1 scale outfile
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var x0:int=int(args[0]); var x1:int=int(args[1]); var y0:int=int(args[2]); var y1:int=int(args[3])
	var scale:int = int(args[4]) if args.size()>4 else 6
	var outfile:String = args[5] if args.size()>5 else "res://tools/_zoom_out.png"
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var et = scn.get_node("EnemyTiles")
	var mk = scn.get_node("Markers")
	var w := (x1-x0)*scale; var h := (y1-y0)*scale
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.02, 0.02, 0.03))
	for yy in range(y0, y1):
		for xx in range(x0, x1):
			var c := Vector2i(xx, yy)
			var col = null
			if terr.get_cell_source_id(c) >= 0:
				var ax: int = terr.get_cell_atlas_coords(c).x
				col = PALETTE.get(ax, Color(0.4,0.4,0.4))
			if et.get_cell_source_id(c) >= 0:
				var ax2: int = et.get_cell_atlas_coords(c).x
				if ax2>=26 and ax2<=28: col = Color(1,1,1)
			if mk.get_cell_source_id(c) >= 0:
				var ax3: int = mk.get_cell_atlas_coords(c).x
				col = Color(0,1,0) if ax3==18 else Color(1,0.7,0)
			if col != null:
				img.fill_rect(Rect2i((xx-x0)*scale, (yy-y0)*scale, scale, scale), col)
	img.save_png(outfile)
	print("saved ", outfile)
	quit()
