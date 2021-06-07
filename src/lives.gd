extends Node

func _ready():
	Lifecounter.lives = 3

func _physics_process(delta):
	if Lifecounter.lives == 2:
		$Life3.hide()
	if Lifecounter.lives == 1:
		$Life2.hide()
	if Lifecounter.lives == 0:
		get_tree().reload_current_scene()
