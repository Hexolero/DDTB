extends KinematicBody2D

const PLAYER_GRAVITY = 200
const PLAYER_JUMP_SPEED = 90.16
var velocity = Vector2(0, 0)

var can_jump = false

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	# jump if able
	if can_jump && (Input.is_key_pressed(KEY_W) || Input.is_key_pressed(KEY_UP)):
		velocity.y -= PLAYER_JUMP_SPEED
		can_jump = false
	
	velocity.y += delta * PLAYER_GRAVITY
	var motion = velocity * delta
	motion = move(motion)
	
	
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
		
		# check if normal is up (i.e, we are on the ground/colliding with it)
		#print(PI - n.angle())
		if abs(PI - n.angle()) < 0.05:
			can_jump = true
	else:
		can_jump = false