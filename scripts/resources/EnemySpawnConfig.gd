class_name EnemySpawnConfig
extends Resource
## Configuration for how an enemy type spawns in a wave

## Enemy to spawn
@export var enemy_data: EnemyData

## Spawn probability weight
@export var spawn_weight: float = 1.0

## Spawn timing constraints
@export var min_spawn_time: float = 0.0  # Earliest time in wave to spawn
@export var max_spawn_time: float = -1.0  # Latest time in wave (-1 = no limit)

## Spawn count limits
@export var min_spawn_count: int = 0
@export var max_spawn_count: int = -1  # -1 = no limit
@export var max_concurrent: int = 5

## Spawn location preferences
@export var spawn_distance_from_player: Vector2 = Vector2(100, 200)  # min/max
@export var preferred_spawn_angle: float = -1.0  # -1 = any angle
@export var angle_variance: float = 360.0

## Special spawn conditions
@export var requires_clear_path: bool = false
@export var avoid_other_enemies: bool = true
@export var spawn_in_groups: bool = false
@export var group_size: Vector2i = Vector2i(1, 1)  # min/max group size

## Validate the spawn configuration
func is_valid() -> bool:
	return (
		enemy_data != null and
		enemy_data.is_valid() and
		spawn_weight > 0.0 and
		min_spawn_time >= 0.0 and
		(max_spawn_time < 0.0 or max_spawn_time >= min_spawn_time) and
		min_spawn_count >= 0 and
		(max_spawn_count < 0 or max_spawn_count >= min_spawn_count) and
		max_concurrent > 0
	)

## Get debug string
func get_debug_string() -> String:
	var enemy_name = enemy_data.display_name if enemy_data else "None"
	return "SpawnConfig[%s]: Weight=%.2f, Max=%d" % [
		enemy_name, spawn_weight, max_concurrent
	]