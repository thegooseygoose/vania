extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	for f in ["walk1","walk2","jump"]:
		var img := Image.load_from_file("res://sprites/player/hal2_%s.png" % f)
		img.resize(img.get_width()*10, img.get_height()*10, Image.INTERPOLATE_NEAREST)
		img.save_png("res://tools/_hal2_%s_zoom.png" % f)
	print("done")
	quit()
