extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://tiles.png")
	var crop := img.get_region(Rect2i(67*16, 0, 32, 16))
	crop.resize(32*12, 16*12, Image.INTERPOLATE_NEAREST)
	crop.save_png("res://tools/_tiles6768_zoom.png")
	print("done")
	quit()
