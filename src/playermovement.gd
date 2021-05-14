extends RigidBody2D

const UP = Vector2(0, 1)
const ENGINE_THRUST = 10
const SPIN_THRUST = 0.01

var thrust = Vector2()
var rot_dir = 0

func get_input(delta):
	thrust = Vector2(0, 0)
	if Input.is_action_pressed("up"):
		thrust = Vector2(ENGINE_THRUST, 0)
	else:
		thrust = Vector2(max(thrust.x - 25, 0), 0)

	rot_dir = 0
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir + 10, 100) * delta
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir - 10, -100) * delta
	else:
		rot_dir = lerp(rot_dir, 0, 10)

func _physics_process(delta):
	get_input(delta)
	set_applied_force((10 * thrust.rotated(rotation)) * delta * UP.y)
	set_applied_torque((rot_dir * SPIN_THRUST) * delta)
