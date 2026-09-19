extends SceneTree
## Renders a region using the REAL tiles.png pixel art (sampled per-tile) instead of a
## flat palette color, so texture patterns are visible in the output.
## Usage: -s tools/_overview_textured.gd -- x0 x1 y0 y1 scale outfile
func _initialize(): call_deferred("_run")
func _run():
	var args := OS.get_cmdline_user_args()
	var x0:int=int(args[0]); var x1:int=int(args[1]); var y0:int=int(args[2]); var y1:int=int(args[3])
	var scale:int = int(args[4]) if args.size()>4 else 8
	var outfile:String = args[5] if args.size()>5 else "res://tools/_zoom_out.png"
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var tiles_img: Image = Image.load_from_file("res://tiles.png")
	var w := (x1-x0)*scale; var h := (y1-y0)*scale
	var img := Image.create(w, h, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.02, 0.02, 0.03))
	for yy in range(y0, y1):
		for xx in range(x0, x1):
			var c := Vector2i(xx, yy)
			if terr.get_cell_source_id(c) < 0: continue
			var ax: int = terr.get_cell_atlas_coords(c).x
			var src := Rect2i(ax*16, 0, 16, 16)
			var tile_crop := tiles_img.get_region(src)
			tile_crop.resize(scale, scale, Image.INTERPOLATE_NEAREST)
			img.blit_rect(tile_crop, Rect2i(0,0,scale,scale), Vector2i((xx-x0)*scale, (yy-y0)*scale))
	img.save_png(outfile)
	print("saved ", outfile)
	quit()
