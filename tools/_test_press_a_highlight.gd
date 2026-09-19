extends SceneTree
## Verifies "A" is red ONLY right after PRESS, and every other control word / plain "A" (as an
## article) across all real POWERUP_DESC strings is classified correctly.

func _initialize(): call_deferred("_run")
func _run() -> void:
	var hud := Hud.new()
	var descs := {
		"square": "PRESS A TO JUMP WHILE IN THE AIR AND JUMP AGAIN.",
		"triangle": "PRESS A TO JUMP AND PRESS DOWN TO SMASH THROUGH BRICKS.",
		"bomb": "DROPS A BOMB WHILE ROLLED UP TO BREAK BLOCKS AND HIT ENEMIES. ROLL UP THEN SHOOT.",
		"star": "FIRES A GRAPPLE ALLOWING YOU TO SWING ACROSS GAPS. HOLD Y TO ACTIVATE.",
		"boomerang": "FIRES A BOLT AT ENEMIES AND SWITCHES. PRESS C OR B ON A CONTROLLER.",
		"riderkick": "A DIVING KICK THAT HITS HARD IN MID-AIR. JUMP THEN PRESS K OR RT.",
		"chargebeam": "HOLD THE SHOT BUTTON TO CHARGE A BLAST WORTH 3 SHOTS. RELEASE TO FIRE.",
	}
	for key in descs:
		var words: Array = String(descs[key]).split(" ")
		var flagged := []
		for i in words.size():
			var prev: String = words[i - 1] if i > 0 else ""
			if hud._is_control_word(words[i]) or hud._is_press_a(words[i], prev):
				flagged.append(words[i])
		print("%s: %s" % [key, str(flagged)])
	hud.free()
	quit()
