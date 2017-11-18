extends Node

func _ready():
	pass

func update_label(val):
	set("text", "SCORE: " + str(val))