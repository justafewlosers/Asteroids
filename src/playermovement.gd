extends KinematicBody2D

const UP = Vector2(0,-1)
const MAX_VEL = 400

var rot_dir = 0
var rot_speed = 5
var motion = Vector2()
var accel = 50
var base_vel = 0

func get_input():
	rot_dir = 0
	motion = Vector2()
#	motion.y = lerp(motion.y, 0, 0.1)
#	motion.x = lerp(motion.x, 0, 0.1)
	if Input.is_action_pressed("right"):
		rot_dir += 1
	if Input.is_action_pressed("left"):
		rot_dir -= 1
	if Input.is_action_pressed("up"):
		motion = Vector2(0, max(abs(motion.y) + accel, MAX_VEL)).rotated(rotation)  * UP.y
#	elif abs(motion.y) > 0:
#		motion = Vector2(lerp(abs(motion.x), 0, 0.1), lerp(abs(motion.y), 0, 0.1)).rotated(rotation)

func _physics_process(delta):
	get_input()
	rotation += rot_dir * rot_speed * delta
	motion = move_and_slide(motion)
