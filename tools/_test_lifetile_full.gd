extends SceneTree
## Confirms: (1) at full HP the station does NOT lock the player, (2) at partial HP it locks +
## plays a looping fill sound, (3) the sound stops when healing finishes or you leave.

var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame

	var life = null
	for n in m.level.get_children():
		if n is LifeStation:
			life = n

	m.player.hp = m.player.MAX_HP
	m.player.global_position = life.global_position + Vector2(2, 0)
	for i in range(10): await physics_frame
	print("FULL HP on tile: heal_lock=%s active=%s sfx=%s" % [str(m.player.heal_lock), str(life._active), str(life._fill_sfx)])

	m.player.hp = 50
	for i in range(10): await physics_frame
	print("dropped to 50 while standing there: heal_lock=%s active=%s sfx_playing=%s"
		% [str(m.player.heal_lock), str(life._active), str(life._fill_sfx != null and life._fill_sfx.playing)])

	for i in range(180): await physics_frame   # 3s -> should top off well before this (50 HP gap / 20 per sec = 2.5s)
	print("after topping off: hp=%s heal_lock=%s active=%s sfx=%s" % [str(m.player.hp), str(m.player.heal_lock), str(life._active), str(life._fill_sfx)])
	quit()
