extends RigidBody2D

export (PackedScene) var bullet

const ENGINE_THRUST = 100
const SPIN_THRUST = 12

var thrust = Vector2()
var rot_dir = 0
var screensize
var sound_played = false

var attack_cooldown = 100
var next_attack_time = 0
var burst = 0
var burst_cap = 3
var burst_cd = 300
var full_auto = false

func _ready():
	screensize = get_viewport().get_visible_rect().size

func blaster():
	if Input.is_action_pressed("shoot"):
		shoot()

func shoot():
	var b = bullet.instance()
	var now = OS.get_ticks_msec()
	if now >= next_attack_time:
		if full_auto == false:
			if burst < burst_cap:
				owner.add_child(b)
				b.transform = $blaster.global_transform
				next_attack_time = now + attack_cooldown
				burst = burst + 1
			elif burst == burst_cap:
				next_attack_time = now + burst_cd
				burst = 0
		elif full_auto == true:
			owner.add_child(b)
			b.transform = $blaster.global_transform
			next_attack_time = now + attack_cooldown
		
func thrust_sound():
	if Input.is_action_just_pressed("up"):
		if !sound_played:
			sound_played = true
			$AudioStreamPlayer.play()
	
func thruster():
	thrust = Vector2(0, 0)
	if Input.is_action_pressed("up"):
		thrust = Vector2(ENGINE_THRUST, 0)
		$plume.visible = true
		thrust_sound()
	else:
		$plume.visible = false
		$AudioStreamPlayer.stop()
		sound_played = false
		
func rotate(delta):
	rot_dir = 0.0
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir + 1, 10) * delta
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir - 1, -10) * delta
	else:
		rot_dir = lerp(rot_dir, 0, 12)

func auto():
	if Input.is_action_just_pressed("rapidfire"):
		if full_auto == false:
			full_auto = true
		elif full_auto == true:
			full_auto = false

func get_input(delta):
	thruster()
	rotate(delta)
	blaster()
	auto()
	
func _physics_process(delta):
	get_input(delta)
	set_applied_force((10 * thrust.rotated(rotation)) * delta)
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
