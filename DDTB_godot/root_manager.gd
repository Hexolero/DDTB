extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

enum game_states { INTRO, GAME, PAUSE }
var current_state = INTRO

var pause_menu_scene
var game_scene

func _ready():
	# get menu tree
	print("Swapped to main game")
	pass

func state_transition(message):
	print("State Transition: " + message)
	if message == "start_pressed" && current_state == INTRO:
		#remove_child(startmenu)
		#add_child(game)
		current_state = GAME