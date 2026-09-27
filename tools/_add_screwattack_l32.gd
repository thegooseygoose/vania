extends SceneTree
## Adds a SCREW ATTACK pickup (Powerups atlas 86) to Level32 (POWER MIX), in the opening room
## next to the other three pickups.
func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level32.tscn").instantiate()
	var pw = scn.get_node("Powerups")
	pw.set_cell(Vector2i(20, 12), 0, Vector2i(86, 0))
	var packed := PackedScene.new(); packed.pack(scn)
	print("saved err=", ResourceSaver.save(packed, "res://Level32.tscn"))
	quit()
