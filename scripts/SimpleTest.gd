extends Node2D

@onready var player = $Player

func _ready():
	print("SimpleTest: Scene loaded successfully!")

func _process(delta):
	# Simple movement
	var input = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		input.x -= 1
	if Input.is_action_pressed("move_right"):
		input.x += 1
	if Input.is_action_pressed("move_up"):
		input.y -= 1
	if Input.is_action_pressed("move_down"):
		input.y += 1
	
	if input.length() > 0:
		player.position += input.normalized() * 200 * delta