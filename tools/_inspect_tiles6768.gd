extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://tiles.png")
	print("tiles.png size: ", img.get_size())
	for col in [67, 68]:
		var x0: int = col * 16
		print("col %d (x=%d..%d):" % [col, x0, x0+15])
		for y in range(16):
			var line := ""
			for x in range(x0, x0+16):
				var c: Color = img.get_pixel(x, y)
				if c.a < 0.05: line += "."
				elif c.r < 0.3 and c.g < 0.3 and c.b < 0.3: line += "#"
				else: line += "o"
			print("  ", line)
	quit()
