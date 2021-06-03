extends KinematicBody2D

var speed: int = 1500
var velocity: Vector2 = Vector2()
var collision: KinematicCollision2D

onready var screen_size: Vector2 = get_viewport_rect().size


func start(pos: Vector2, dir: float):
	rotation = dir
	position = pos
	velocity = Vector2(speed, 0).rotated(rotation)

func _ready():
	var t: Timer = Timer.new()
	t.set_wait_time(0.4)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	queue_free()

func _physics_process(delta):
	screenwrap()
	collision = move_and_collide(velocity * delta)

func screenwrap():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y
