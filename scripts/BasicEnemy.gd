extends CharacterBody2D

signal died

var player_ref: Node2D
var base_speed: float = 100.0
var current_health: int = 50
var max_health: int = 50

func _ready():
	player_ref = get_tree().get_first_node_in_group("player")
	max_health = get_meta("max_health", 50)
	current_health = max_health
	base_speed = get_meta("speed", 100.0)

func _physics_process(_delta: float):
	if not get_meta("active", false) or not is_instance_valid(player_ref):
		return
	
	var direction = (player_ref.global_position - global_position).normalized()
	velocity = direction * base_speed
	move_and_slide()

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	died.emit()
	
	if EnemyPool:
		EnemyPool.return_enemy(self)
