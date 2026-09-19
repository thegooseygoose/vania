extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var src := Image.load_from_file("res://sprites/v sprites/BLOKZ.png")
	var tiles := Image.load_from_file("res://tiles.png")
	# CORRECT full-icon crops (white border + black fill + white X/O), exactly 16x16, no distortion:
	var b1 := src.get_region(Rect2i(5, 29, 16, 16))    # BLOCK1 / X
	var b2 := src.get_region(Rect2i(75, 33, 16, 16))   # BLOCK2 / O
	tiles.blit_rect(b1, Rect2i(Vector2i.ZERO, Vector2i(16, 16)), Vector2i(67*16, 0))
	tiles.blit_rect(b2, Rect2i(Vector2i.ZERO, Vector2i(16, 16)), Vector2i(68*16, 0))
	tiles.save_png("res://tiles.png")
	print("corrected BLOKZ tiles to the TRUE 16x16 art (white border included), saved")
	quit()
