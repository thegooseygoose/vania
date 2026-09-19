extends SceneTree
## Adds one LifeStation (health-refill icon) to Level29/Brinstar, placed on the last standable
## shelf (y=432) just before the final drop shaft down to the goal (175,449) -- i.e. just before
## the end of the level.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var scn = load("res://Level29.tscn").instantiate()

	var ls := Area2D.new()
	ls.name = "Life1"
	ls.set_script(load("res://lifestation.gd"))
	ls.position = Vector2(169 * 16 + 8, 433 * 16)
	scn.add_child(ls)
	ls.owner = scn

	var packed := PackedScene.new()
	packed.pack(scn)
	var err := ResourceSaver.save(packed, "res://Level29.tscn")
	print("added Life1 at %s, save err=%d" % [str(ls.position), err])
	quit()
