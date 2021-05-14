extends KinematicBody2D

const UP = Vector2(0,-1)

var rot_dir = 0
var rot_speed = 5
var velocity = Vector2()
var accel = 50
var max_vel = 400

func add_velocity():
	if velocity.y < max_vel:
		velocity.y += -accel
		velocity = Vector2(0, -velocity.y).rotated(rotation)
		

func velocity():
	if velocity.y > 0:
		velocity.y = lerp(0, velocity.y, 0.2)
	
func get_input():
	rot_dir = 0
	if Input.is_action_pressed("right"):
		rot_dir += 1
	if Input.is_action_pressed("left"):
		rot_dir -= 1
	if Input.is_action_pressed("up"):
		add_velocity()
	else:
		velocity()
		
func _physics_process(delta):
	get_input()
	rotation += rot_dir * rot_speed * delta
	velocity = move_and_slide(velocity)
