extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://sprites/v sprites/BLOKZ.png")
	# print a wider region around BLOCK1's black square (detected bbox was x=6..19,y=30..43)
	# to see what's in the 1px ring just outside it (x=74..91, y=32..49)
	print("BLOCK2 region x=74..91 y=32..49 (B=opaque black, W=opaque white, .=transparent, ?=other):")
	for y in range(32, 50):
		var line := "y=%2d: " % y
		for x in range(74, 92):
			var c: Color = img.get_pixel(x, y)
			if c.a < 0.1: line += "."
			elif c.r > 0.8 and c.g > 0.8 and c.b > 0.8: line += "W"
			elif c.r < 0.3 and c.g < 0.3 and c.b < 0.3: line += "B"
			else: line += "?"
		print(line)
	quit()
