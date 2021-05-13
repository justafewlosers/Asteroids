extends KinematicBody2D

const UP = Vector2(0,-1)

var rot_dir = 0
var rot_speed = 5
var velocity = Vector2()
var accel = 50
var max_vel = 400

func add_velocity():
	if velocity.y < max_vel:
		velocity.y += accel
	elif velocity.y == max_vel:
		pass

func velocity():
	if velocity.y > 0:
		velocity.y -= accel
	
func get_input():
	#velocity = Vector2()
	rot_dir = 0
	if Input.is_action_pressed("right"):
		rot_dir += 1
	if Input.is_action_pressed("left"):
		rot_dir -= 1
	if Input.is_action_pressed("up"):
		print("Hello, World")
		add_velocity()
	else:
		velocity()
		
func _physics_process(delta):
	get_input()
	rotation += rot_dir * rot_speed * delta
	velocity = move_and_slide(velocity, velocity).rotated(rotation) * UP.y
