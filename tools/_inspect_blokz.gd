extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://sprites/v sprites/BLOKZ.png")
	print("image size: ", img.get_size())
	# scan two rough halves (left=BLOCK1, right=BLOCK2) for the actual glyph bbox (non-background pixels)
	# sample a background color from a corner to know what counts as "background"
	var bg: Color = img.get_pixel(0, 0)
	print("bg color @ (0,0) = ", bg)
	for label in ["BLOCK1", "BLOCK2"]:
		var x0 := 0 if label == "BLOCK1" else 50
		var x1 := 50 if label == "BLOCK1" else 100
		var minx := 9999; var maxx := -9999; var miny := 9999; var maxy := -9999
		for y in range(0, img.get_height()):
			for x in range(x0, x1):
				var c: Color = img.get_pixel(x, y)
				var d: float = absf(c.r-bg.r) + absf(c.g-bg.g) + absf(c.b-bg.b)
				if c.a > 0.05 and d > 0.05:
					minx = mini(minx, x); maxx = maxi(maxx, x)
					miny = mini(miny, y); maxy = maxi(maxy, y)
		print("%s glyph bbox (any non-bg pixel, includes text label): x=[%d..%d] y=[%d..%d] size=(%d x %d)" % [
			label, minx, maxx, miny, maxy, maxx - minx + 1, maxy - miny + 1])
	quit()
