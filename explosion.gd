extends Node2D
## A chunky, low-framerate PIXEL-ART explosion: an expanding fireball built from square
## "pixel" chunks that steps through a hot→cool palette (white core → yellow → orange → red),
## grows a jagged rim, throws off a few debris chunks, then fades and frees itself.
## Drop one in the world at the death position; it self-animates. No texture — pure draw_rect.

const DUR := 0.42               # total life (short + punchy)
const FRAMES := 6               # stepped animation frames (low fps = pixel-art feel)
const PX := 2.0                 # size of one chunk in px (bigger = chunkier)
const MAX_R := 3                # peak radius in chunks -> (2*3+1)*2 = 14px, inside a 16x16 box
const RADII := [1, 2, 3, 3, 2, 2]   # fireball radius (in chunks) per frame: grow, peak, collapse

var t := 0.0
var _debris: Array = []         # fixed random debris directions (chosen once so they fly straight)

func _ready() -> void:
	z_index = 20
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 7:
		var a := rng.randf() * TAU
		_debris.append(Vector2(cos(a), sin(a)))
	set_process(true)

func _process(delta: float) -> void:
	t += delta
	if t >= DUR:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var f: int = clampi(int(t / DUR * FRAMES), 0, FRAMES - 1)
	var R: int = RADII[f]
	var fade := 1.0
	if f >= 4:
		fade = clampf(1.0 - (float(f) - 3.0) / 3.0, 0.0, 1.0)   # fade over the last two frames
	# a stable-per-frame RNG so the jagged edge doesn't shimmer across the many redraws of one frame
	var rr := RandomNumberGenerator.new()
	rr.seed = 1013 + f * 99991
	for cy in range(-R, R + 1):
		for cx in range(-R, R + 1):
			var d := sqrt(float(cx * cx + cy * cy))
			if d > float(R) + 0.5:
				continue
			# jagged, broken rim — drop ~half the outermost chunks
			if d > float(R) - 1.0 and rr.randf() < 0.5:
				continue
			var nd: float = d / maxf(1.0, float(R))
			var col: Color
			if nd < 0.34:
				col = Color(1.0, 1.0, 0.90)    # white-hot core
			elif nd < 0.60:
				col = Color(1.0, 0.86, 0.22)   # yellow
			elif nd < 0.85:
				col = Color(1.0, 0.48, 0.10)   # orange
			else:
				col = Color(0.82, 0.15, 0.08)  # red rim
			col.a = fade
			_chunk(cx, cy, col)
	# dark debris chunks on the rim (clamped inside the box so the whole FX stays 16x16)
	if f >= 2:
		var rim: int = mini(f - 1, MAX_R)          # push out to the rim, never past MAX_R chunks
		for v in _debris:
			var dcx: int = clampi(int(round(v.x * float(rim))), -MAX_R, MAX_R)
			var dcy: int = clampi(int(round(v.y * float(rim))), -MAX_R, MAX_R)
			_chunk(dcx, dcy, Color(0.45, 0.11, 0.07, fade))

# draw one chunk, integer-aligned so pixels stay crisp (no sub-pixel blur)
func _chunk(cx: int, cy: int, col: Color) -> void:
	var ox := floorf(float(cx) * PX - PX * 0.5)
	var oy := floorf(float(cy) * PX - PX * 0.5)
	draw_rect(Rect2(ox, oy, PX, PX), col)
