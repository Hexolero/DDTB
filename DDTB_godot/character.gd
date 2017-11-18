extends KinematicBody2D

const PLAYER_GRAVITY = 200
const PLAYER_JUMP_SPEED = 90.16
var velocity = Vector2(0, 0)
var can_jump = false
var in_air = true

onready var anim_player = get_node("../anim")
onready var sound_player = get_node("sounds")

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# jump if able
	if can_jump && (Input.is_key_pressed(KEY_W) || Input.is_key_pressed(KEY_UP)):
		velocity.y -= PLAYER_JUMP_SPEED
		anim_player.play("jump_up")
		sound_player.play("jump")
		can_jump = false
		in_air = true
	
	# change to falling animation
	if !can_jump && velocity.y > 0 && anim_player.get_current_animation() == "jump_up":
		anim_player.play("fall")
	
	velocity.y += delta * PLAYER_GRAVITY
	var motion = velocity * delta
	motion = move(motion)
	# lock x-axis position - note that this causes some small collision bugs at times
	set_pos(Vector2(0, get_pos().y))
	
	
	if (is_colliding()):
		var n = get_collision_normal()
		var n_angle = n.angle()
		
		# check if we're landing and animate accordingly
		if n_angle >= 5*PI/8 && n_angle <= 11*PI/8 && in_air:
			anim_player.play("run")
			in_air = false
		
		# this code causes more realistic movement, but doesn't play well with incoming slopes for an infinite runner
		#motion = n.slide(motion)
		#velocity = n.slide(velocity)
		#move(motion)
		
		# check if normal is up (i.e, we are on the ground/colliding with it)
		if n_angle >= 5*PI/8 && n_angle <= 11*PI/8:
			velocity.y = 0
			can_jump = true
	else:
		can_jump = false
		# start falling if possible
		if !in_air && velocity.y > 5:
			in_air = true
			anim_player.play("fall")