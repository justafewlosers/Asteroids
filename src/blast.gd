extends Area2D

var speed = 1500

onready var screen_size = get_viewport_rect().size

func _ready():
	var t = Timer.new()
	t.set_wait_time(0.4)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	yield(t, "timeout")
	queue_free()
		
func _physics_process(delta):
	screenwrap()
	position += transform.x * speed * delta

func screenwrap():
	if position.x > screen_size.x:
		position.x = 0
	if position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	if position.y < 0:
		position.y = screen_size.y
