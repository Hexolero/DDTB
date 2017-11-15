extends Node

func _ready():
	set_process(true)
	
func _process(delta):
	if Input.is_key_pressed(KEY_RETURN):
		get_tree().change_scene("res://game.tscn")

func _on_startbutton_pressed():
	get_tree().change_scene("res://game.tscn")