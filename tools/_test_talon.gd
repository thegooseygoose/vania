extends SceneTree
var m
func _initialize(): call_deferred("_run")
func _run() -> void:
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 14
	m = load("res://Main.tscn").instantiate()
	get_root().add_child(m)
	for i in range(30): await physics_frame
	print("level_file=", m._level_file, " enemies=", m.enemies.size())

	var talon = null
	for e in m.enemies:
		if e.kind == "talon": talon = e
	if talon == null:
		print("FAIL: no talon enemy found")
		quit(); return
	print("talon found: pos=", talon.global_position, " hp=", talon.talon_hp, " state=", talon.talon_state,
		" rect=", talon.rect.size, " home=", talon.talon_home)

	# move the player near the talon room so it activates + is on-screen
	m.player.global_position = talon.global_position + Vector2(0, 40)
	for i in range(10): await physics_frame
	print("after settle: talon.active=", talon.active, " state=", talon.talon_state)

	# run enough frames to observe a full patrol->telegraph->diving->recovering cycle
	var states_seen := {}
	var dive_hit_player := false
	var start_hp = m.player.hp
	for i in range(260):
		states_seen[talon.talon_state] = true
		await physics_frame
		if m.player.hp < start_hp and not dive_hit_player:
			dive_hit_player = true
			print("player took damage at frame ", i, " (hp ", start_hp, "->", m.player.hp, ") during talon state cycle")
	print("states observed over 260 frames: ", states_seen.keys())
	print("talon pos after cycle=", talon.global_position, " state=", talon.talon_state)

	# verify shot-kill: boomerang_kill should chip HP and eventually explode it
	var hp0 = talon.talon_hp
	talon.boomerang_kill(1, 1)
	print("after 1 shot: hp ", hp0, "->", talon.talon_hp, " dead=", talon.dead)
	# stomp/dash should NOT kill it (SHOT-only)
	var hp1 = talon.talon_hp
	talon.knock_out(1)
	print("after knock_out() (should no-op): hp still=", talon.talon_hp, " (expected ", hp1, ", dead=", talon.dead, ")")
	# finish it off
	while talon.talon_hp > 0 and not talon.dead:
		talon.boomerang_kill(1, 1)
	print("after lethal shots (pre-cleanup): dead=", talon.dead, " remove_me=", talon.remove_me)
	for i in range(5): await physics_frame
	print("still in enemies list after cleanup frames: ", m.enemies.has(talon), " (expect false, removed+freed)")
	quit()
