extends SceneTree
## Rasterizes the new energy-bolt shot (boomerang.gd _draw, USE_NEW_BOOM) onto an image so it
## can be eyeballed enlarged. Mirrors the draw sequence with alpha-blended discs.
## Run: --headless -s tools/preview_shot.gd  ->  tools/_shot_preview.png

const S := 6.0     # upscale so the ~12px bolt is visible
var img: Image

func _init() -> void:
	var w := 240
	var h := 96
	img = Image.create(w, h, false, Image.FORMAT_RGBA8)
	for y in h:
		for x in w:
			# left half = dark navy (game bg), right half = a lit grey, to judge contrast on both
			img.set_pixel(x, y, Color(0.06, 0.08, 0.11) if x < w / 2 else Color(0.22, 0.24, 0.18))
	_bolt(Vector2(w * 0.28, h * 0.5))
	_bolt(Vector2(w * 0.72, h * 0.5))
	img.save_png("res://tools/_shot_preview.png")
	print("wrote tools/_shot_preview.png")
	quit()

# draw the bolt centred at image-space point `c` (dir = +1, flick = 1.0), local units scaled by S
func _bolt(c: Vector2) -> void:
	var d := 1.0
	var g := Color(0.25, 0.7, 1.0)
	_disc(c, 6.0, Color(g.r, g.g, g.b, 0.14))
	_disc(c, 4.0, Color(g.r, g.g, g.b, 0.30))
	for i in range(6):
		var fx := float(i)
		var px := -d * (2.0 + fx * 2.3)
		var rad: float = maxf(0.6, 2.8 - fx * 0.45)
		var a: float = clampf(0.75 - fx * 0.12, 0.0, 1.0)
		_disc(c + Vector2(px, 0.0) * S, rad, Color(0.45, 0.85, 1.0, a))
	_disc(c + Vector2(d * 1.6, 0.0) * S, 2.6, Color(0.8, 0.97, 1.0, 0.95))
	_disc(c + Vector2(d * 1.6, 0.0) * S, 1.4, Color(1.0, 1.0, 1.0, 1.0))

# filled disc: centre in image space, radius in bolt-space (scaled by S), alpha-blended
func _disc(center: Vector2, radius: float, col: Color) -> void:
	var r := radius * S
	var x0 := int(floor(center.x - r))
	var x1 := int(ceil(center.x + r))
	var y0 := int(floor(center.y - r))
	var y1 := int(ceil(center.y + r))
	for y in range(max(0, y0), min(img.get_height(), y1 + 1)):
		for x in range(max(0, x0), min(img.get_width(), x1 + 1)):
			var dx := float(x) + 0.5 - center.x
			var dy := float(y) + 0.5 - center.y
			if dx * dx + dy * dy > r * r:
				continue
			var bg := img.get_pixel(x, y)
			var a := col.a
			img.set_pixel(x, y, Color(
				lerp(bg.r, col.r, a), lerp(bg.g, col.g, a), lerp(bg.b, col.b, a), 1.0))
