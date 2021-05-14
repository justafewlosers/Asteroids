extends RigidBody2D

const UP = Vector2(0, 1)

var thrust = Vector2()
var engine_thrust = 200
var spin_thrust = 15
var rot_dir = 0
var screensize

func _ready():
	screensize = get_viewport().get_visible_rect().size
	
func thruster():
	thrust = Vector2(0, 0)
	if Input.is_action_pressed("up"):
		thrust = Vector2(engine_thrust, 0)
	else:
		thrust = Vector2(max(thrust.x, 0), 0)
		
func rotate(delta):
	rot_dir = 0.0
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir + 1, 10) * delta
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir - 1, -10) * delta
	else:
		rot_dir = lerp(rot_dir, 0, 12)
	
func get_input(delta):
	thruster()
	rotate(delta)
	
func _physics_process(delta):
	get_input(delta)
	set_applied_force((10 * thrust.rotated(rotation)) * delta * UP.y)
	set_applied_torque((rot_dir * spin_thrust) * delta)
	
func _integrate_forces(state):
	var xform = state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	state.set_transform(xform)
