extends SceneTree
## Rasterizes explosion.gd's frames directly onto an Image (no Viewport / no GPU, so it works
## headless) so the pixel-art look can be eyeballed. Mirrors explosion.gd's _draw math 1:1.
## Run: --headless -s tools/preview_explosion.gd  ->  tools/_explosion_preview.png

const PX := 2
const FRAMES := 6
const MAX_R := 3
const RADII := [1, 2, 3, 3, 2, 2]

func _init() -> void:
	var cell := 40
	var img := Image.create(cell * FRAMES, cell, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.05, 0.06, 0.09))
	var cx0 := cell / 2
	var cy0 := cell / 2

	var debris: Array = []
	var rng := RandomNumberGenerator.new()
	rng.seed = 42
	for i in 7:
		var a := rng.randf() * TAU
		debris.append(Vector2(cos(a), sin(a)))

	for f in FRAMES:
		var ox0 := f * cell
		var R: int = RADII[f]
		var fade := 1.0
		if f >= 4:
			fade = clampf(1.0 - (float(f) - 3.0) / 3.0, 0.0, 1.0)
		var rr := RandomNumberGenerator.new()
		rr.seed = 1013 + f * 99991
		for cy in range(-R, R + 1):
			for cx in range(-R, R + 1):
				var d := sqrt(float(cx * cx + cy * cy))
				if d > float(R) + 0.5:
					continue
				if d > float(R) - 1.0 and rr.randf() < 0.5:
					continue
				var nd: float = d / maxf(1.0, float(R))
				var col: Color
				if nd < 0.34: col = Color(1.0, 1.0, 0.90)
				elif nd < 0.60: col = Color(1.0, 0.86, 0.22)
				elif nd < 0.85: col = Color(1.0, 0.48, 0.10)
				else: col = Color(0.82, 0.15, 0.08)
				col.a = fade
				_chunk(img, ox0 + cx0, cy0, cx, cy, col)
		if f >= 2:
			var rim: int = mini(f - 1, MAX_R)
			for v in debris:
				var dcx: int = clampi(int(round(v.x * float(rim))), -MAX_R, MAX_R)
				var dcy: int = clampi(int(round(v.y * float(rim))), -MAX_R, MAX_R)
				_chunk(img, ox0 + cx0, cy0, dcx, dcy, Color(0.45, 0.11, 0.07, fade))

	img.save_png("res://tools/_explosion_preview.png")
	print("wrote tools/_explosion_preview.png")
	quit()

func _chunk(img: Image, base_x: int, base_y: int, cx: int, cy: int, col: Color) -> void:
	var ox := base_x + int(floor(float(cx) * PX - PX * 0.5))
	var oy := base_y + int(floor(float(cy) * PX - PX * 0.5))
	for yy in PX:
		for xx in PX:
			var px := ox + xx
			var py := oy + yy
			if px < 0 or py < 0 or px >= img.get_width() or py >= img.get_height():
				continue
			# alpha-blend over the existing pixel
			var bg := img.get_pixel(px, py)
			var a := col.a
			img.set_pixel(px, py, Color(
				lerp(bg.r, col.r, a), lerp(bg.g, col.g, a), lerp(bg.b, col.b, a), 1.0))
