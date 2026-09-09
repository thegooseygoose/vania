extends SceneTree
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode=false; Main.save_slot=-1; Main.debug_start_level=13
	var m=load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(50): await physics_frame
	m.start_delay=0.0; m.fade_alpha=0.0
	print("before: frozen=%s freeze_t=%.2f"%[str(m.actors_frozen()), m.powerup_freeze_t])
	m.collect_powerup("square")
	print("on collect: freeze_t=%.2f frozen=%s music_paused=%s"%[m.powerup_freeze_t, str(m.actors_frozen()), str(m.music_player.stream_paused if m.music_player else false)])
	for i in range(110): await physics_frame   # ~1.8s
	print("after ~1.8s: freeze_t=%.2f frozen=%s music_paused=%s"%[m.powerup_freeze_t, str(m.actors_frozen()), str(m.music_player.stream_paused if m.music_player else false)])
	quit()
