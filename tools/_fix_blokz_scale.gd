extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var src := Image.load_from_file("res://sprites/v sprites/BLOKZ.png")
	var tiles := Image.load_from_file("res://tiles.png")
	# BLOCK1 (X) source box (6,30)-(20,44) exclusive = 14x14 -> upscale to 16x16, paste at col67
	var b1 := src.get_region(Rect2i(6, 30, 14, 14))
	b1.resize(16, 16, Image.INTERPOLATE_NEAREST)
	tiles.blit_rect(b1, Rect2i(Vector2i.ZERO, Vector2i(16,16)), Vector2i(67*16, 0))
	# BLOCK2 (O) source box (76,34)-(90,48) exclusive = 14x14 -> upscale to 16x16, paste at col68
	var b2 := src.get_region(Rect2i(76, 34, 14, 14))
	b2.resize(16, 16, Image.INTERPOLATE_NEAREST)
	tiles.blit_rect(b2, Rect2i(Vector2i.ZERO, Vector2i(16,16)), Vector2i(68*16, 0))
	tiles.save_png("res://tiles.png")
	print("rescaled BLOKZ tiles to fill full 16x16, saved")
	quit()
