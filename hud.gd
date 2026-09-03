extends CanvasLayer
class_name Hud
## Score / coins / world / time readout + COURSE CLEAR overlay, drawn with the
## hand-made bitmap font `sprites/new player/LETTERS 1.png` (uppercase A-Z, the
## digits and a period). Everything is painted by a single Control child so the
## text stays fixed while the camera scrolls.

var main                       # untyped to avoid a cyclic class dependency
var font: PixelFont
var coins_tex: Texture2D       # 3 coin spin frames (16px each), shared with the world
var course_tex: Texture2D      # "COURSE CLEARED!!!" card (purple box; time drawn inside it)
var _canvas: Control
var _msg_text := ""
var _msg_hide_ms := 0

# ---- minimap (fog-of-war) ----
var map_seen := {}             # Vector2i cell -> true : tiles revealed by exploring
var _map_level := -999         # which level file the current fog belongs to (reset on change)
var _map_rect := Rect2i()      # the level's terrain bounds (px-per-tile scale is derived from it)
const MAP_REVEAL := 7          # tiles revealed in each direction around Mario


func _ready() -> void:
	font = PixelFont.new()
	coins_tex = load("res://sprites/coins.png")
	course_tex = load("res://sprites/new player/COURSE.png")
	_canvas = HudCanvas.new()
	_canvas.hud = self
	_canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_canvas.size = Vector2(main.VIEW_W, main.VIEW_H)
	add_child(_canvas)


func show_message(text: String, seconds := 3.0) -> void:
	_msg_text = text
	_msg_hide_ms = Time.get_ticks_msec() + int(seconds * 1000.0)


func refresh() -> void:
	if _msg_text != "" and Time.get_ticks_msec() >= _msg_hide_ms:
		_msg_text = ""
	if _canvas:
		_canvas.queue_redraw()


func _paint(ci: CanvasItem) -> void:
	var w := float(main.VIEW_W)
	# OVERCLOCK: a blue wash over the screen while time is slowed
	if main.world_slow < 1.0:
		ci.draw_rect(Rect2(0, 0, w, float(main.VIEW_H)), Color(0.2, 0.5, 1.0, 0.16))
	# 3-4 end credits: the overworld run-and-scroll finale takes over the whole screen
	if main.game_state == "credits":
		_paint_credits(ci)
		return
	# between-level black card: full black, ONLY the next-level name centred
	if main.show_level_card:
		ci.draw_rect(Rect2(0, 0, w, float(main.VIEW_H)), Color.BLACK)
		font.draw_text(ci, Vector2(0, main.VIEW_H / 2.0 - 6), main.level_card_text, 2.0, Color.WHITE, w)
		return
	# top status row — score / MARIO / coins removed; the minimap lives in that top-left space now
	font.draw_text(ci, Vector2(150, 11), "WORLD", 1.0, Color.WHITE)
	font.draw_text(ci, Vector2(159, 21), main.world_label, 1.0, Color.WHITE)
	font.draw_text(ci, Vector2(206, 11), "TIME", 1.0, Color.WHITE)
	font.draw_text(ci, Vector2(206, 21), main.time_string(), 1.0, Color.WHITE)

	# fog-of-war minimap (top-right) during normal play
	if main.game_state == "play" and not main.show_level_card and not main.attract_mode:
		_paint_minimap(ci)
	# 5-heart health readout (top-left, under the score)
	if main.player != null and not main.show_level_card:
		_paint_hearts(ci)

	# attract/demo mode banner
	if main.attract_mode:
		font.draw_text(ci, Vector2(0, 31), "- DEMO -", 1.0, Color(1.0, 0.85, 0.2), w)
		if fmod(main.qanim_phase, 0.8) < 0.5:
			font.draw_text(ci, Vector2(0, float(main.VIEW_H) - 11), "PRESS START", 1.0, Color.WHITE, w)

	# COURSE CLEAR overlay — the "COURSE CLEARED!!!" card with the finish time in its box
	if main.game_state == "clear":
		var cscale := 0.35
		var cw2: float = float(course_tex.get_width()) * cscale
		var ch2: float = float(course_tex.get_height()) * cscale
		var cx2: float = (w - cw2) / 2.0
		var cy2: float = (float(main.VIEW_H) - ch2) / 2.0 - 38.0
		if main._level_file == 15:
			# DK stage (2-4): drop the card lower so it doesn't cover Amazon up top
			cy2 = clampf(main.player.global_position.y + 20.0, 20.0, float(main.VIEW_H) - ch2 - 6.0)
		# transparent interior — the card is just the purple frame + text over the live scene
		ci.draw_texture_rect(course_tex, Rect2(cx2, cy2, cw2, ch2), false)
		# the finish time, centred inside the lower purple box
		font.draw_text(ci, Vector2(cx2, cy2 + ch2 * 0.72), "TIME " + main.time_string(), 1.0, Color.WHITE, cw2)
		# NEW RECORD flash under the card when this clear beat the file's best time
		if main._new_record and fmod(main.qanim_phase, 0.5) < 0.32:
			font.draw_text(ci, Vector2(0, cy2 + ch2 + 12.0), "NEW RECORD", 1.0, Color(1.0, 0.85, 0.2), w)

	# Level10 Sonic preview: name the current animation at the bottom
	if main.sonic_demo:
		var nm: String = String(main.sonic_state).to_upper() + "  " + ("RIGHT" if main.sonic_face == "r" else "LEFT")
		font.draw_text(ci, Vector2(0, float(main.VIEW_H) - 12), nm, 1.0, Color(0.5, 1.0, 0.6), w)

	# mac's rescue line (Bowser's castle) — centred lines in a dark band, shown after
	# Mario reaches him and BEFORE the COURSE CLEAR card
	if main.show_rescue_speech:
		var lines: Array = main.AM_SPEECH_LINES if main._rescue_is_am else main.RESCUE_SPEECH_LINES
		var char_h: float = float(main.AM_H) if main._rescue_is_am else float(main.MAC_H)
		var lh := 12.0          # same line height / size as Sonic's speech
		var mx: float = main.rescue_pos.x - main.cam_x     # the character's on-screen centre
		var boxw := 0.0
		for ln in lines:
			boxw = maxf(boxw, font.text_w(String(ln), 1.0))
		boxw += 12.0
		mx = clampf(mx, boxw / 2.0 + 2.0, w - boxw / 2.0 - 2.0)
		# sit the block directly above the character's head (feet at rescue_pos.y, sprite char_h tall)
		var boxh: float = lh * lines.size() + 6.0
		var by: float = (main.rescue_pos.y - char_h) - 6.0 - boxh
		ci.draw_rect(Rect2(mx - boxw / 2.0, by, boxw, boxh), Color(0.04, 0.04, 0.06, 1.0))
		var yy := by + 10.0
		for ln in lines:
			var lw2: float = font.text_w(String(ln), 1.0)
			font.draw_text(ci, Vector2(mx - lw2 / 2.0, yy), String(ln), 1.0, Color(1.0, 0.92, 0.35))
			yy += lh

	# 1-2 Sonic cutscene: his "congratulations / take the pipe" line, floating near him
	if main.sonic_speech:
		var slines: Array = main.sonic_speech_lines
		var sx: float = main.sonic_x - main.cam_x          # Sonic's on-screen x (camera is locked)
		var lh := 12.0
		var stop := 104.0
		if main._l14_prejump:
			stop -= 32.0                                   # L14 "HERE'S YOUR PRIZE, PAL!" sits higher
		var boxw := 0.0
		for ln in slines:
			boxw = maxf(boxw, font.text_w(String(ln), 1.0))
		boxw += 12.0
		sx = clampf(sx, boxw / 2.0 + 2.0, w - boxw / 2.0 - 2.0)
		ci.draw_rect(Rect2(sx - boxw / 2.0, stop - 10.0, boxw, lh * slines.size() + 6.0), Color(0.05, 0.05, 0.08, 0.92))
		var syy := stop
		for ln in slines:
			var lw2: float = font.text_w(String(ln), 1.0)
			font.draw_text(ci, Vector2(sx - lw2 / 2.0, syy), String(ln), 1.0, Color(1.0, 0.92, 0.35))
			syy += lh

	# transient centred message (e.g. power-up instructions) — small so it fits on screen
	if _msg_text != "":
		font.draw_text(ci, Vector2(0, main.VIEW_H / 3.0), _msg_text, 1.0, Color(1.0, 0.6, 0.75), w)

	# stage-start fade-in: a black veil over the whole screen that fades to clear
	if main.fade_alpha > 0.0:
		ci.draw_rect(Rect2(0, 0, w, float(main.VIEW_H)), Color(0, 0, 0, main.fade_alpha))

	# pause menu (drawn last so it sits on top of everything)
	if main.paused:
		_paint_pause(ci, w)


func reset_map() -> void:
	map_seen.clear()
	_map_level = -999


# 5-heart health, drawn top-left under the score. Filled = current, dark = lost.
const _HEART := ["0110110", "1111111", "1111111", "0111110", "0011100", "0001000"]
func _paint_hearts(ci: CanvasItem) -> void:
	var cur: int = int(main.player.hearts)
	var maxh: int = int(main.player.MAX_HEARTS)
	var hy := 12.0                          # top row, to the RIGHT of the minimap (before WORLD)
	for i in maxh:
		var hx := 92.0 + float(i) * 9.0
		var col := Color(0.95, 0.2, 0.32) if i < cur else Color(0.24, 0.24, 0.30)
		for ry in _HEART.size():
			var row: String = _HEART[ry]
			for rx in row.length():
				if row[rx] == "1":
					ci.draw_rect(Rect2(hx + float(rx), hy + float(ry), 1.0, 1.0), col)


# A small fog-of-war minimap in the top-right: the whole level scaled to fit a fixed box,
# revealed as Mario explores. Walls brown, water blue, lava red, hooks yellow, goal gold,
# Mario a blinking green blip.
func _paint_minimap(ci: CanvasItem) -> void:
	if main.terrain == null or main.player == null:
		return
	var tile: float = float(main.TILE)
	if _map_level != main._level_file:                 # fog belongs to one level; reset on change
		_map_level = main._level_file
		map_seen.clear()
		_map_rect = main.terrain.get_used_rect()
	var rect := _map_rect
	if rect.size.x <= 0 or rect.size.y <= 0:
		return
	var pc := Vector2i(int(floor(main.player.global_position.x / tile)), int(floor(main.player.global_position.y / tile)))
	for dy in range(-MAP_REVEAL, MAP_REVEAL + 1):       # reveal a radius around Mario
		for dx in range(-MAP_REVEAL, MAP_REVEAL + 1):
			map_seen[pc + Vector2i(dx, dy)] = true
	var boxw := 80.0
	var boxh := 50.0
	var scale: float = minf(boxw / float(rect.size.x), boxh / float(rect.size.y))
	var mw: float = float(rect.size.x) * scale
	var mh: float = float(rect.size.y) * scale
	var ox := 5.0                                       # TOP-LEFT (replaces the old score/MARIO/coins)
	var oy := 10.0
	ci.draw_rect(Rect2(ox - 2, oy - 2, mw + 4, mh + 4), Color(0.9, 0.9, 1.0, 0.85))   # frame
	ci.draw_rect(Rect2(ox - 1, oy - 1, mw + 2, mh + 2), Color(0.06, 0.06, 0.12, 0.85)) # backdrop
	var cs: float = maxf(1.0, ceil(scale))
	for cell in map_seen:
		if not rect.has_point(cell):
			continue
		var mx: float = ox + float(cell.x - rect.position.x) * scale
		var my: float = oy + float(cell.y - rect.position.y) * scale
		var src: int = main.terrain.get_cell_source_id(cell)
		if src < 0:
			ci.draw_rect(Rect2(mx, my, cs, cs), Color(0.26, 0.28, 0.40, 0.55))   # explored open space
			continue
		var ax: int = main.terrain.get_cell_atlas_coords(cell).x
		var col := Color(0.72, 0.55, 0.32)                                       # wall / terrain
		if ax == 19: col = Color(1.0, 0.85, 0.2)                                 # goal
		elif ax == 45 or ax == 46: col = Color(0.42, 0.62, 1.0)                  # water
		elif ax == 28 or ax == 29: col = Color(0.95, 0.35, 0.2)                  # lava
		elif ax == 47: col = Color(1.0, 1.0, 0.35)                               # hook
		ci.draw_rect(Rect2(mx, my, cs, cs), col)
	# Mario blip (blinks so it stands out)
	if fmod(main.qanim_phase, 0.5) < 0.35:
		var px: float = ox + float(pc.x - rect.position.x) * scale
		var py: float = oy + float(pc.y - rect.position.y) * scale
		ci.draw_rect(Rect2(px - 1, py - 1, cs + 2, cs + 2), Color(0.3, 1.0, 0.4))


func _paint_pause(ci: CanvasItem, w: float) -> void:
	var h := float(main.VIEW_H)
	var sel := int(main.pause_sel)
	# dim the frozen game, then a framed panel
	ci.draw_rect(Rect2(0, 0, w, h), Color(0, 0, 0, 0.72))
	var pw := 180.0
	var px := (w - pw) / 2.0
	var py := 44.0
	var ph := 162.0
	ci.draw_rect(Rect2(px, py, pw, ph), Color(0.10, 0.10, 0.16, 0.96))
	ci.draw_rect(Rect2(px, py, pw, 2), Color.WHITE)
	ci.draw_rect(Rect2(px, py + ph - 2, pw, 2), Color.WHITE)
	ci.draw_rect(Rect2(px, py, 2, ph), Color.WHITE)
	ci.draw_rect(Rect2(px + pw - 2, py, 2, ph), Color.WHITE)

	font.draw_text(ci, Vector2(0, py + 24), "PAUSED", 2.0, Color.WHITE, w)

	_paint_vol_row(ci, py + 52, "MUSIC", main.music_volume, sel == 0)
	_paint_vol_row(ci, py + 74, "SOUND", main.sfx_volume, sel == 1)
	_paint_filter_row(ci, py + 96, sel == 2)
	_paint_action_row(ci, py + 120, "MAIN MENU", sel == 3)

	# controls hint
	var hint := Color(0.7, 0.7, 0.78)
	font.draw_text(ci, Vector2(0, py + ph - 14), "UP DOWN PICK   LEFT RIGHT SET", 1.0, hint, w)
	font.draw_text(ci, Vector2(0, py + ph - 5), "ESC RESUME   ENTER SELECT", 1.0, hint, w)


# A plain selectable row (no slider), e.g. MAIN MENU. `by` is the text baseline.
func _paint_action_row(ci: CanvasItem, by: float, label: String, selected: bool) -> void:
	var lx := (float(main.VIEW_W) - 180.0) / 2.0 + 14.0
	var col := Color(1.0, 0.85, 0.2) if selected else Color.WHITE
	if selected:
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(lx - 10, by - 6), Vector2(lx - 4, by - 3), Vector2(lx - 10, by)]), col)
	font.draw_text(ci, Vector2(lx, by), label, 1.0, col)


# One "LABEL [######----] 60" row. `by` is the text baseline.
func _paint_vol_row(ci: CanvasItem, by: float, label: String, vol: float, selected: bool) -> void:
	var lx := (float(main.VIEW_W) - 180.0) / 2.0 + 14.0
	var col := Color(1.0, 0.85, 0.2) if selected else Color.WHITE
	if selected:
		# little cursor triangle to the left of the row
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(lx - 10, by - 6), Vector2(lx - 4, by - 3), Vector2(lx - 10, by)]), col)
	font.draw_text(ci, Vector2(lx, by), label, 1.0, col)
	# 10-segment bar
	var bx := lx + 42.0
	var bw := 80.0
	var bh := 7.0
	var top := by - 7.0
	ci.draw_rect(Rect2(bx, top, bw, bh), Color(0.06, 0.06, 0.1))
	var segs := 10
	var gap := 1.0
	var sw := (bw - gap * (segs - 1)) / segs
	var lit := int(round(vol * segs))
	for i in segs:
		var sx := bx + i * (sw + gap)
		var on := i < lit
		var c := col if on else Color(0.28, 0.28, 0.34)
		ci.draw_rect(Rect2(sx, top, sw, bh), c)
	ci.draw_rect(Rect2(bx - 1, top - 1, bw + 2, bh + 2), col, false, 1.0)
	# percentage
	font.draw_text(ci, Vector2(bx + bw + 6, by), str(int(round(vol * 100))), 1.0, col)


# "FILTER  < CRT >" row — cycles the display filter instead of a volume bar.
func _paint_filter_row(ci: CanvasItem, by: float, selected: bool) -> void:
	var lx := (float(main.VIEW_W) - 180.0) / 2.0 + 14.0
	var col := Color(1.0, 0.85, 0.2) if selected else Color.WHITE
	if selected:
		ci.draw_colored_polygon(PackedVector2Array([
			Vector2(lx - 10, by - 6), Vector2(lx - 4, by - 3), Vector2(lx - 10, by)]), col)
	font.draw_text(ci, Vector2(lx, by), "FILTER", 1.0, col)
	var fname: String = main.FILTER_NAMES[int(main.filter_mode)]
	var vx := lx + 46.0             # where the value block starts
	var vw := 78.0                  # value block width (matches the bars' span)
	# left / right cycle arrows framing the current filter name
	var midy := by - 3.0
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(vx, midy), Vector2(vx + 5, midy - 4), Vector2(vx + 5, midy + 4)]), col)
	ci.draw_colored_polygon(PackedVector2Array([
		Vector2(vx + vw, midy), Vector2(vx + vw - 5, midy - 4), Vector2(vx + vw - 5, midy + 4)]), col)
	# filter name centred between the arrows
	font.draw_text(ci, Vector2(vx + 8, by), fname, 1.0, col, vw - 16.0)


# ---- 3-4 END CREDITS ----
# Only the scrolling credit lines — the real overworld level + running Mario render
# beneath (this HUD sits on top), so we draw text over a transparent screen. Lines crawl
# up and settle with "THE END" holding near the top.
func _paint_credits(ci: CanvasItem) -> void:
	var w := float(main.VIEW_W)
	var start_y: float = main.CREDITS_START_Y                  # first item enters just above Mario's lane
	var scroll_max: float = main._credits_scroll_max()
	var scroll: float = minf(main.credits_t * main.CREDITS_SCROLL_SPD, scroll_max)
	var y := start_y - scroll
	for it in main._credits_items():
		var h: float = float(it["h"])
		if y > -h and y < start_y + 4.0:
			if it["kind"] == "text":
				var txt := String(it["text"])
				if txt != "":
					var c: Array = it["col"]
					font.draw_text(ci, Vector2(0, y), txt, float(it["scale"]), Color(c[0], c[1], c[2]), w)
			else:
				_paint_cast(ci, w, y, String(it["key"]), String(it["name"]))
		y += h


# one enemy portrait (scaled to ~26px tall, centred) with its name beneath it
func _paint_cast(ci: CanvasItem, w: float, y: float, key: String, nm: String) -> void:
	var t: Texture2D = main.tex.get(key)
	if t != null:
		var sz := t.get_size()
		var target := 26.0
		var s: float = target / maxf(1.0, sz.y)
		var dw := sz.x * s
		var dh := sz.y * s
		ci.draw_texture_rect(t, Rect2(floorf((w - dw) / 2.0), floorf(y - dh), dw, dh), false)
	font.draw_text(ci, Vector2(0, y + 10.0), nm, 1.0, Color.WHITE, w)


# The actual drawing surface: a Control so the HUD stays screen-fixed.
class HudCanvas extends Control:
	var hud
	func _draw() -> void:
		hud._paint(self)
