extends SceneTree
func _initialize(): call_deferred("_run")
func _step(n): for i in range(n): await physics_frame

func _run() -> void:
	Main.save_slot=-1; Main.debug_start_level=1
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	await _step(40)
	m.start_delay=0.0; m.fade_alpha=0.0
	var p = m.player

	# GoalStar node present + wired?
	var goal = null
	for c in m.level.get_children():
		if c.get_script() == load("res://goal.gd"): goal = c
	print("GoalStar node present=%s wired=%s" % [str(goal != null), str(goal != null and goal.main == m)])

	# hurt while FIRE -> drops to big (mushroom), not small, stays alive
	p.dead=false; p.transforming=false; p.invuln=0.0; p.big=true; p.fire=true
	p.hurt()
	print("HURT fire: fire=%s big=%s dead=%s (want fire=false big=true alive)" % [str(p.fire), str(p.big), str(p.dead)])

	# hurt while just BIG -> death (no shrink to small)
	p.dead=false; p.transforming=false; p.invuln=0.0; p.big=true; p.fire=false
	p.hurt()
	print("HURT big: dead=%s transforming=%s (want dead=true, NOT a shrink)" % [str(p.dead), str(p.transforming)])

	# respawn tier after death: saved_tier should be big and reset makes him big
	p.died_by_pit=false; p.dead_timer=99.0
	await _step(3)
	print("AFTER RESPAWN: saved_tier=%s player.big=%s (want big / true)" % [str(m.saved_tier), str(m.player.big)])

	# touch the goal -> COURSE CLEAR
	m.player.global_position = goal.global_position
	await _step(4)
	print("TOUCH GOAL: game_state=%s (want clear)" % str(m.game_state))

	print("DONE")
	quit()
