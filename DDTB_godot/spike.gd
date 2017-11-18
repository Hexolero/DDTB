extends Sprite

var game_over = false

func _ready():
	pass

func _on_spike_area_body_enter( body ):
	# don't handle spike code when game has already ended
	if game_over:
		return
	print("SPIKE")
	print(body.get_name())
	if body.get_name() == "character_body":
		get_tree().call_group(2, "game_participants", "game_over")
		game_over = true