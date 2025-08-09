extends Node2D

@onready var player = $Player
@onready var enemy_counter_label = $UI/GameUI/EnemyCounter

var enemies: Array[CharacterBody2D] = []
var max_enemies: int = 5
var spawn_timer: float = 0.0
var spawn_interval: float = 2.0

func _ready():
	print("WorkingArena: Starting...")
	add_to_group("arena")
	
	# Spawn first enemy after delay
	await get_tree().create_timer(1.0).timeout
	spawn_simple_enemy()

func _process(delta: float):
	# Spawn enemies up to max
	if enemies.size() < max_enemies:
		spawn_timer += delta
		if spawn_timer >= spawn_interval:
			spawn_timer = 0.0
			spawn_simple_enemy()
	
	# Update UI
	enemy_counter_label.text = "Enemies: %d/%d" % [enemies.size(), max_enemies]
	
	# Simple movement for player
	handle_player_movement(delta)

func handle_player_movement(delta: float):
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
		
		# Keep player in arena bounds
		player.position.x = clamp(player.position.x, 50, 750)
		player.position.y = clamp(player.position.y, 50, 550)

func spawn_simple_enemy():
	print("WorkingArena: Spawning enemy...")
	
	# Create simple enemy
	var enemy = CharacterBody2D.new()
	enemy.name = "Enemy" + str(enemies.size())
	
	# Add red sprite
	var sprite = ColorRect.new()
	sprite.size = Vector2(16, 16)
	sprite.position = Vector2(-8, -8)
	sprite.color = Color.RED
	enemy.add_child(sprite)
	
	# Position at edge of arena
	var spawn_angle = randf() * TAU
	var spawn_pos = Vector2(400, 300) + Vector2.from_angle(spawn_angle) * 200
	spawn_pos.x = clamp(spawn_pos.x, 50, 750)
	spawn_pos.y = clamp(spawn_pos.y, 50, 550)
	enemy.position = spawn_pos
	
	# Add to scene
	add_child(enemy)
	enemies.append(enemy)
	
	print("WorkingArena: Spawned enemy at %s" % spawn_pos)

func _physics_process(delta: float):
	# Move enemies toward player
	for enemy in enemies:
		if is_instance_valid(enemy) and is_instance_valid(player):
			var direction = (player.position - enemy.position).normalized()
			enemy.position += direction * 50 * delta  # Slow enemy speed