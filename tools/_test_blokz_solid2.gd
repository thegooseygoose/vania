extends SceneTree
## Direct unit check of the patched helper functions against the real BLOKZ tiles now painted at
## Level29 (28,200-204)=atlas67, (29-30,205)=atlas68 — no physics simulation needed, just calls the
## same functions the player's movement code calls every frame.
func _initialize(): call_deferred("_run")
func _run():
	Main.attract_mode = false; Main.save_slot = -1; Main.debug_start_level = 13
	var m = load("res://Main.tscn").instantiate(); get_root().add_child(m)
	for i in range(10): await physics_frame
	if not m.player:
		print("NO PLAYER"); quit(); return
	var p = m.player
	# _ground_top_at(px, feet_y): top y of a solid tile under px near feet_y
	var top67 = p._ground_top_at(28*16+8, 200*16 + 2.0)   # just below the atlas-67 block top at row200
	var top68 = p._ground_top_at(29*16+8, 205*16 + 2.0)   # just below the atlas-68 block top at row205
	print("ground_top_at over atlas67 block (row200): %.1f  (expect %.1f if solid, -inf if not)" % [top67, 200.0*16])
	print("ground_top_at over atlas68 block (row205): %.1f  (expect %.1f if solid, -inf if not)" % [top68, 205.0*16])
	quit()
