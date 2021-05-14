extends RigidBody2D

const UP = Vector2(0, 1)
const ENGINE_THRUST = 100
const SPIN_THRUST = 15

var thrust = Vector2()
var rot_dir = 0
var screensize

func _ready():
	screensize = get_viewport().get_visible_rect().size
	
func thruster():
	thrust = Vector2(0, 0)
	if Input.is_action_pressed("up"):
		thrust = Vector2(ENGINE_THRUST, 0)
		$plume.visible = true
	else:
		thrust = Vector2(max(thrust.x, 0), 0)
		$plume.visible = false
		
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
	set_applied_torque((rot_dir * SPIN_THRUST) * delta)
	
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
