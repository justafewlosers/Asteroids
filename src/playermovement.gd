extends RigidBody2D

export (PackedScene) var bullet
export (PackedScene) var blast
export (PackedScene) var spawn
export (PackedScene) var explode

const ENGINE_THRUST = 100
const SPIN_THRUST = 12

#movement variables
var thrust = Vector2()
var rot_dir = 0
var screensize
var sound_played = false

#attack variables
var attack_cooldown
var next_attack_time = 0
var burst = 0
var burst_cap = 4
var burst_cd = 450
var full_auto = false
var can_shoot

var is_dead

func _ready():
	screensize = get_viewport().get_visible_rect().size

#screenwrapping
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

#toggles fire mode
func auto():
	if Input.is_action_just_pressed("rapidfire"):
		full_auto = ! full_auto

#checks ability to shoot and shoots
func shoot():
	var b = bullet.instance()
	var c = blast.instance()
	var now = OS.get_ticks_msec()
	if now >= next_attack_time:
		if full_auto == false:
			if burst < burst_cap:
				can_shoot = true
				attack_cooldown = 100
				burst = burst + 1
			elif burst == burst_cap:
				can_shoot = false
				next_attack_time = now + burst_cd
				burst = 0
		elif full_auto:
			attack_cooldown = 200
			can_shoot = true
		if can_shoot:
			var t = Timer.new()
			owner.add_child(b)
			owner.add_child(c)
			b.transform = $blaster.global_transform
			c.transform = $blaster.global_transform
			next_attack_time = now + attack_cooldown
			t.set_wait_time(0.03)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			owner.remove_child(c)
			

#input for shooting
func blaster():
	if Input.is_action_pressed("shoot"):
		shoot()

#audio controller for thrust
func thrust_sound():
	if !sound_played:
		sound_played = true
		$AudioStreamPlayer.play()

#defines thrust var and controls thrust vfx and sfx
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

#defines rotation variable
func rotate(delta):
	rot_dir = 0.0
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir + 1, 10) * delta
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir - 1, -10) * delta
	else:
		rot_dir = lerp(rot_dir, 0, 12)

#death controller
func die():
	is_dead = true
	var t = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	owner.remove_child(spawn)

#groups all control componenet major functions
func get_input(delta):
	thruster()
	rotate(delta)
	blaster()
	auto()

#runs per physics update | sets force and torque
func _physics_process(delta):
	if is_dead:
		pass
	else:
		get_input(delta)
	set_applied_force((10 * thrust.rotated(rotation)) * delta)
	set_applied_torque((rot_dir * SPIN_THRUST) * delta)
