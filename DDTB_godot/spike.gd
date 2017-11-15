extends Sprite

func _ready():
	pass

func _on_spike_body_enter( body ):
	print("SPIKE")
	print(body.get_name())
	if body.get_name() == "character_body":
		get_tree().call_group(2, "root", "game_over")