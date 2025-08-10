class_name WaveConfiguration
extends Resource
## Resource for configuring enemy spawn waves
## Makes wave spawning data-driven and easily configurable

## Wave identification
@export var wave_id: String = ""
@export var wave_name: String = ""
@export var description: String = ""

## Timing configuration
@export var wave_duration: float = 60.0
@export var spawn_interval: float = 2.0
@export var spawn_interval_variance: float = 0.5

## Enemy spawn configuration
@export var enemy_spawn_configs: Array[EnemySpawnConfig] = []
@export var max_concurrent_enemies: int = 10
@export var total_enemy_budget: int = 50

## Difficulty scaling
@export var difficulty_multiplier: float = 1.0
@export var health_multiplier: float = 1.0
@export var speed_multiplier: float = 1.0
@export var damage_multiplier: float = 1.0

## Special conditions
@export var boss_spawn: EnemyData
@export var boss_spawn_time: float = -1.0  # -1 means no boss
@export var environmental_effects: Array[String] = []

## Get total spawn weight for probability calculations
func get_total_spawn_weight() -> float:
	var total_weight: float = 0.0
	for config in enemy_spawn_configs:
		if config and config.enemy_data:
			total_weight += config.spawn_weight
	return total_weight

## Get a random enemy data based on spawn weights
func get_random_enemy_data() -> EnemyData:
	var total_weight = get_total_spawn_weight()
	if total_weight <= 0.0:
		return null
	
	var random_value = randf() * total_weight
	var current_weight: float = 0.0
	
	for config in enemy_spawn_configs:
		if config and config.enemy_data:
			current_weight += config.spawn_weight
			if random_value <= current_weight:
				return config.enemy_data
	
	# Fallback to first available
	for config in enemy_spawn_configs:
		if config and config.enemy_data:
			return config.enemy_data
	
	return null

## Validate the wave configuration
func is_valid() -> bool:
	return (
		wave_id != "" and
		wave_name != "" and
		wave_duration > 0.0 and
		spawn_interval > 0.0 and
		enemy_spawn_configs.size() > 0 and
		max_concurrent_enemies > 0
	)