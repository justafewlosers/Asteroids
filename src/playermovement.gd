extends RigidBody2D

const UP = Vector2(0, 1)
const MAX_VEL = 400
const MAX_TORQUE = 20

var thrust = Vector2()
var engine_thrust = 10
var spin_thrust = 0.01
var rot_dir = 0

func get_input(delta):
	thrust = Vector2(0, 0)
	if Input.is_action_pressed("up"):
		thrust = Vector2(engine_thrust, 0)
	else:
		thrust = Vector2(max(thrust.x - 25, 0), 0)

	rot_dir = 0
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir - 1, -10) * delta
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir + 1, 10) * delta
	else:
		rot_dir = lerp(rot_dir, 0, 10)

func _physics_process(delta):
	get_input(delta)
	set_applied_force((10 * thrust.rotated(rotation)) * delta * UP.y)
	set_applied_torque((rot_dir * spin_thrust) * delta)
