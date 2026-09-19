extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	var img := Image.load_from_file("res://sprites/v sprites/BLOKZ.png")
	img.resize(img.get_width()*8, img.get_height()*8, Image.INTERPOLATE_NEAREST)
	img.save_png("res://tools/_blokz_zoom.png")
	print("saved zoom, size=", img.get_size())
	quit()
