extends KinematicBody2D

const PLAYER_GRAVITY = 200
const PLAYER_JUMP_SPEED = 90.16
const COMBO_TIMEOUT = 1 # length of time (in seconds) player can stay in able to jump state without game over
const SCORE_JUMP_DECREMENT = 1.5 # amount to subtract from the player's score when they jump

var velocity = Vector2(0, 0)
var can_jump = false
var in_air = true
var dead = false
var combo = 0
var combo_timer = 0
var score = 0

onready var anim_player = get_node("../anim")
onready var sound_player = get_node("sounds")

func _ready():
	set_fixed_process(true)
	set_process(true)

func _process(delta):
	if dead:
		return
	score += delta
	get_tree().call_group(2, "score", "update_label", int(ceil(score * 100)))

func _fixed_process(delta):
	# skip usual update when player is dead
	if dead:
		velocity.y += delta * PLAYER_GRAVITY
		var motion = velocity * delta
		motion = move(motion)
		
		if is_colliding():
			# tell the game to stop
			get_tree().call_group(2, "game_participants", "death_landed")
		return
	
	#print(combo_timer)
	# if able to jump, increment combo timer
	print(can_jump)
	if can_jump && !in_air:
		combo_timer += delta
		get_tree().call_group(2, "timer", "update_frame", combo_timer / COMBO_TIMEOUT)
		if combo_timer >= COMBO_TIMEOUT:
			get_tree().call_group(2, "game_participants", "game_over")
	
	if get_pos().y >= 96:
		get_tree().call_group(2, "game_participants", "game_over")
		get_tree().call_group(2, "game_participants", "death_landed")
	
	# jump if able
	if can_jump && (Input.is_key_pressed(KEY_W) || Input.is_key_pressed(KEY_UP)):
		velocity.y -= PLAYER_JUMP_SPEED
		anim_player.play("jump_up")
		sound_player.play("jump")
		can_jump = false
		in_air = true
		
		# reset combo
		combo += 1
		combo_timer = 0
		get_tree().call_group(2, "timer", "update_frame", 0)
		
		# decrement score
		score -= SCORE_JUMP_DECREMENT
	
	# change to falling animation
	if !can_jump && velocity.y > 0 && anim_player.get_current_animation() == "jump_up":
		anim_player.play("fall")
	
	velocity.y += delta * PLAYER_GRAVITY
	var motion = velocity * delta
	motion = move(motion)
	# lock x-axis position - note that this causes some small collision bugs at times
	if !in_air:
		set_pos(Vector2(0, get_pos().y))
	
	
	if is_colliding():
		var n = get_collision_normal()
		var n_angle = n.angle()
		
		print(n_angle)
		
		# check if we're landing and animate accordingly
		if (n_angle >= 5*PI/8 || n_angle <= -5*PI/8) && in_air:
			anim_player.play("run")
			in_air = false
		
		# this code causes more realistic movement, but doesn't play well with incoming slopes for an infinite runner
		#motion = n.slide(motion)
		#velocity = n.slide(velocity)
		#move(motion)
		
		# check if normal is up (i.e, we are on the ground/colliding with it)
		if n_angle >= 5*PI/8 || n_angle <= -5*PI/8:
			velocity.y = 0
		if n_angle >= 15*PI/16 || n_angle <= -15*PI/16:
			can_jump = true
		else:
			can_jump = false
	else:
		can_jump = false
		# start falling if possible
		if !in_air && velocity.y > 5:
			in_air = true
			anim_player.play("fall")

func game_over():
	anim_player.play("death")
	sound_player.play("death")
	dead = true