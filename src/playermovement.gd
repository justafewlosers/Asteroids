extends RigidBody2D

export (PackedScene) var bullet
export (PackedScene) var blast

const ENGINE_THRUST = 100
const SPIN_THRUST = 12

var thrust = Vector2()
var rot_dir: float = 0.0
var screensize
var sound_played = false

var attack_cooldown
var next_attack_time = 0
var burst = 0
var burst_cap = 4
var burst_cd = 450
var full_auto = false
var can_shoot

func _ready():
	screensize = get_viewport().get_visible_rect().size

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

func auto():
	if Input.is_action_just_pressed("rapidfire"):
		full_auto = ! full_auto

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
			t.set_wait_time(0.1)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			owner.remove_child(c)
			

func blaster():
	if Input.is_action_pressed("shoot"):
		shoot()

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
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir + 100, 1000)
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir - 100, -1000)
	else:
		rot_dir = lerp(rot_dir, 0, 1)

func get_input(delta):
	thruster()
	rotate(delta)
	blaster()
	auto()

func _physics_process(delta):
	get_input(delta)
	set_applied_force((10 * thrust.rotated(rotation)) * delta)
	set_applied_torque((rot_dir * SPIN_THRUST) * delta)
