extends SceneTree
const PALETTE := {
	69: Color8(0xD8,0x28,0x00), 70: Color8(0xBC,0xBC,0xBC), 71: Color8(0x00,0x90,0x38),
	72: Color8(0xC8,0x4C,0x0C), 73: Color8(0x74,0x74,0x74), 74: Color8(0x80,0x00,0xF0),
	75: Color8(0x00,0x70,0xEC), 76: Color8(0x00,0x80,0x88), 77: Color8(0xE4,0x00,0x58),
	78: Color8(0xBC,0x00,0xBC), 79: Color8(0x00,0x94,0x00), 80: Color8(0x00,0x00,0xA8),
}
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn").instantiate()
	var terr = scn.get_node("Terrain")
	var mk = scn.get_node("Markers")
	var et = scn.get_node("EnemyTiles")
	const W := 480; const H := 450
	var img := Image.create(W, H, false, Image.FORMAT_RGBA8)
	img.fill(Color(0.02, 0.02, 0.03))
	for c in terr.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = terr.get_cell_atlas_coords(c).x
		img.set_pixel(c.x, c.y, PALETTE.get(ax, Color(0.4,0.4,0.4)))
	for c in et.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = et.get_cell_atlas_coords(c).x
		if ax >= 26 and ax <= 28: img.set_pixel(c.x, c.y, Color(1,1,1))
		elif ax in [24,25,29,31,35]: img.set_pixel(c.x, c.y, Color(1,1,0))
		elif ax == 30: img.set_pixel(c.x, c.y, Color(1,0,0))
	for c in mk.get_used_cells():
		if c.x < 0 or c.x >= W or c.y < 0 or c.y >= H: continue
		var ax: int = mk.get_cell_atlas_coords(c).x
		img.set_pixel(c.x, c.y, Color(0,1,0) if ax==18 else Color(1,0.7,0))
	img.save_png("res://tools/_overview_colored.png")
	print("saved")
	quit()
