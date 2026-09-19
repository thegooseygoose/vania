extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://sprites/v sprites/BLOKZ.png")
	# scan for the solid BLACK square specifically (near-black, opaque), separately per half,
	# restricted to y>=20 to skip the text label row
	for label in ["BLOCK1", "BLOCK2"]:
		var x0 := 0 if label == "BLOCK1" else 70
		var x1 := 50 if label == "BLOCK1" else 100
		var minx := 9999; var maxx := -9999; var miny := 9999; var maxy := -9999
		for y in range(30, img.get_height()):
			for x in range(x0, x1):
				var c: Color = img.get_pixel(x, y)
				if c.a > 0.5 and c.r < 0.3 and c.g < 0.3 and c.b < 0.3:
					minx = mini(minx, x); maxx = maxi(maxx, x)
					miny = mini(miny, y); maxy = maxi(maxy, y)
		print("%s BLACK-square bbox: x=[%d..%d] y=[%d..%d] size=(%d x %d)" % [
			label, minx, maxx, miny, maxy, maxx - minx + 1, maxy - miny + 1])
	quit()
