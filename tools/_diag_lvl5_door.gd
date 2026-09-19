extends SceneTree
## Confirms the Level5 door/switch geometry: is the switch actually reachable/shootable from
## before the door, or is it sealed on the far side (soft-lock)?
func _initialize(): call_deferred("_run")
func _run():
	var scn = load("res://Level29.tscn")  # unused, just keep parser happy
	var s5 = load("res://Level5.tscn").instantiate()
	var terr = s5.get_node("Terrain")
	var mk = s5.get_node("Markers")
	print("Terrain solidity around door1 (x=117..125, y=0..7):")
	for y in range(0, 8):
		var line := "y=%2d: " % y
		for x in range(117, 126):
			var solid: bool = terr.get_cell_source_id(Vector2i(x, y)) >= 0
			var mark: int = mk.get_cell_atlas_coords(Vector2i(x, y)).x if mk.get_cell_source_id(Vector2i(x, y)) >= 0 else -1
			if mark == 17: line += "D"
			elif mark == 16: line += "S"
			elif solid: line += "#"
			else: line += "."
		print(line)
	quit()
