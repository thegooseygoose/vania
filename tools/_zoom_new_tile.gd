extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://tiles.png")
	for col in [72, 75]:
		var crop := img.get_region(Rect2i(col*16, 0, 16, 16))
		crop.resize(16*10, 16*10, Image.INTERPOLATE_NEAREST)
		crop.save_png("res://tools/_atlas%d_zoom.png" % col)
	print("done")
	quit()
