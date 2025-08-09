extends Node

# Game state management and wave spawning

var current_wave: int = 0
var enemies_remaining: int = 0
var game_paused: bool = false

func _ready():
	print("GameManager initialized")
	# Connect to events
	EventBus.enemy_died.connect(_on_enemy_died)

func start_wave(wave_number: int):
	current_wave = wave_number
	enemies_remaining = _calculate_wave_size(wave_number)
	EventBus.wave_started.emit(wave_number)
	print("Wave %d started with %d enemies" % [wave_number, enemies_remaining])

func _calculate_wave_size(wave: int) -> int:
	# Scale enemy count with wave, capped at 150 for performance
	return min(10 + wave * 5, 150)

func _on_enemy_died(enemy: Node2D):
	enemies_remaining = max(0, enemies_remaining - 1)
	
	if enemies_remaining == 0:
		EventBus.wave_completed.emit(current_wave)
		print("Wave %d completed!" % current_wave)