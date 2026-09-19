extends SceneTree
## Adds one LifeStation (health-refill icon) to Level30 (the ENEMIES showcase level), placed on
## the floor a few tiles before the goal (359,13) -- i.e. just before the end of the level.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level30.tscn").instantiate()

	var ls := Area2D.new()
	ls.name = "Life1"
	ls.set_script(load("res://lifestation.gd"))
	ls.position = Vector2(352 * 16 + 8, 14 * 16)
	scn.add_child(ls)
	ls.owner = scn

	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level30.tscn")
	print("added Life1 at %s, save err=%d" % [str(ls.position), err])
	quit()
