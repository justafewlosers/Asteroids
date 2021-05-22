extends RigidBody2D

export (PackedScene) var bullet: PackedScene
export (PackedScene) var blast: PackedScene
export (PackedScene) var spawn
export (PackedScene) var explode: PackedScene

const ENGINE_THRUST = 100
const SPIN_THRUST = 12

#movement variables
var thrust = Vector2()
var rot_dir: float = 0.0
var screensize: Vector2
var sound_played = false

#attack variables
var attack_cooldown: int
var next_attack_time: int = 0
var burst: int = 0
var burst_cap: int = 4
var burst_cd: int = 450
var full_auto: bool = false
var can_shoot: bool

var is_dead

func _ready():
	screensize = get_viewport().get_visible_rect().size

#screenwrapping
func _integrate_forces(state: Physics2DDirectBodyState):
	var xform: Transform2D = state.get_transform()
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
	var now: int = OS.get_ticks_msec()
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
			var b: KinematicBody2D = bullet.instance() as KinematicBody2D
			var c: Area2D = blast.instance() as Area2D
			b.start($blaster.global_position, rotation)
			owner.add_child(b)
			$blastfx.add_child(c)
			var t: Timer = Timer.new()
			next_attack_time = now + attack_cooldown
			t.set_wait_time(0.1)
			t.set_one_shot(true)
			self.add_child(t)
			t.start()
			yield(t, "timeout")
			$blastfx.remove_child(c)
			

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
func get_rotate():
	if Input.is_action_pressed("right"):
		rot_dir = min(rot_dir + 100, 1000)
	elif Input.is_action_pressed("left"):
		rot_dir = max(rot_dir - 100, -1000)
	else:
		rot_dir = lerp(rot_dir, 0, 1)

#death controller
func die():
	is_dead = true
	var t: Timer = Timer.new()
	t.set_wait_time(1)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	owner.remove_child(spawn)

#groups all control componenet major functions
func get_input():
	thruster()
	get_rotate()
	blaster()
	auto()

#runs per physics update | sets force and torque
func _physics_process(delta):
	if is_dead:
		pass
	else:
		get_input()
	set_applied_force((10 * thrust.rotated(rotation)) * delta)
	set_applied_torque((rot_dir * SPIN_THRUST) * delta)
