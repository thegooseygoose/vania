extends SceneTree
func _initialize(): call_deferred("_run")
func _run() -> void:
	var Player = load("res://player.gd")
	var p = Player.new()
	var tex = p._make_ball_tex()
	var img: Image = tex.get_image()
	# upscale 8x nearest for a visible preview
	img.resize(img.get_width()*8, img.get_height()*8, Image.INTERPOLATE_NEAREST)
	img.save_png("user://ball_preview.png")
	print("saved ", ProjectSettings.globalize_path("user://ball_preview.png"))
	quit()
