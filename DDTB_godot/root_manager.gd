extends Node

const room_packedscenes = [preload("rooms/room_empty.tscn"), preload("rooms/room_plateau.tscn"), preload("rooms/room_plateau_2.tscn"), preload("rooms/room_plateau_3.tscn"), preload("rooms/room_plateau_4.tscn")]
var room_corners = []
var columns # stores containers of 3 rooms each

var game_speed = 80 # multiplied into frame delta
var game_over = false

# represents the two middle-right corners of the 1x3 column of rooms that has been most recently generated
# first element is BR corner, second element is TR corner
var current_corners = [0, 0]

func _ready():
	# get menu tree
	print("Swapped to main game")
	set_process(true)
	columns = get_node("columns")
	
	for packedscene in room_packedscenes:
		var room = packedscene.instance()
		room_corners.append({ TL = room.TL, TR = room.TR, BL = room.BL, BR = room.BR })
		room.queue_free()

func _process(delta):
	if game_over:
		# restart
		if Input.is_key_pressed(KEY_R):
			get_tree().change_scene("res://startmenu.tscn")
		return
	columns.set_pos(columns.get_pos() - Vector2(game_speed * delta, 0))
	for col in columns.get_children():
		if col.get_global_pos().x <= -192:
			col.queue_free()
			columns.remove_child(col)
			spawn_new_rooms(col.get_pos().x + 192)

func spawn_new_rooms(h_adjustment):
	var possible_rooms = []
	var chosen_rooms = []
	var new_corners = []
	# generate new bottom room
	for i in range(room_corners.size()):
		if room_corners[i].TL == current_corners[0] && room_corners[i].BL == 1:
			possible_rooms.append(room_packedscenes[i].instance())
	chosen_rooms.append(possible_rooms[randi() % possible_rooms.size()])
	possible_rooms.clear() # clear array for re-use
	new_corners.append(chosen_rooms[0].TR)
	
	# generate new middle room
	for i in range(room_corners.size()):
		if room_corners[i].BL == current_corners[0] && room_corners[i].BR == new_corners[0]:
			possible_rooms.append(room_packedscenes[i].instance())
	chosen_rooms.append(possible_rooms[randi() % possible_rooms.size()])
	possible_rooms.clear() # clear array for re-use
	new_corners.append(chosen_rooms[1].TR)
	
	# generate new top room
	for i in range(room_corners.size()):
		if room_corners[i].BL == current_corners[1] && room_corners[i].BR == new_corners[1] && room_corners[i].TR == 0:
			possible_rooms.append(room_packedscenes[i].instance())
	chosen_rooms.append(possible_rooms[randi() % possible_rooms.size()])
	
	# finalize spawning
	current_corners = new_corners
	var new_column = Node2D.new()
	new_column.set_global_pos(Vector2(192 + h_adjustment, 0))
	columns.add_child(new_column)
	for i in range(3):
		chosen_rooms[i].set_pos(Vector2(0, -160 * i))
		new_column.add_child(chosen_rooms[i])
	
	print(chosen_rooms[0].get_name())

# this is where end of game cleanup occurs
func death_landed():
	# ignore multiple calls to this function
	if game_over:
		return
	game_over = true
	print("GAME OVER")
	
	#get_tree().change_scene("res://game.tscn")