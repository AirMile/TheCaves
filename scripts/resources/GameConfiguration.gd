class_name GameConfiguration
extends Resource
## Resource for overall game configuration and balance settings
## Makes game balance easily tweakable without code changes

## Game identification
@export var config_name: String = "Default"
@export var version: String = "1.0"
@export var description: String = ""

## Player configuration
@export var player_starting_health: int = 100
@export var player_starting_speed: float = 200.0
@export var player_starting_damage: int = 15
@export var player_dash_speed: float = 400.0
@export var player_dash_duration: float = 0.2
@export var player_dash_cooldown: float = 1.0

## Experience and leveling
@export var base_experience_to_level: int = 100
@export var experience_scaling_factor: float = 1.2
@export var max_player_level: int = 100

## Arena settings
@export var arena_size: Vector2 = Vector2(800, 600)
@export var arena_background_color: Color = Color(0.2, 0.2, 0.3, 1.0)
@export var wall_thickness: float = 20.0

## Performance settings
@export var max_enemies: int = 150
@export var max_projectiles: int = 500
@export var target_fps: int = 60
@export var physics_tick_rate: int = 60

## Spawn system settings
@export var enemy_spawn_margin: float = 50.0  # Distance from arena edges
@export var min_spawn_distance_from_player: float = 100.0
@export var max_spawn_distance_from_player: float = 250.0

## Difficulty scaling
@export var difficulty_curve_steepness: float = 1.1
@export var enemy_health_scaling: float = 1.05  # Per level
@export var enemy_damage_scaling: float = 1.03  # Per level
@export var enemy_speed_scaling: float = 1.02   # Per level

## Audio settings
@export var master_volume: float = 1.0
@export var music_volume: float = 0.7
@export var sfx_volume: float = 0.8
@export var ui_volume: float = 0.6

## UI settings
@export var show_debug_info: bool = false
@export var show_fps: bool = false
@export var debug_toggle_key: String = "F3"

## Wave progression
@export var waves: Array[WaveConfiguration] = []
@export var loop_final_wave: bool = true
@export var wave_difficulty_increase: float = 0.1  # Per loop

## Validate configuration
func is_valid() -> bool:
	return (
		config_name != "" and
		player_starting_health > 0 and
		player_starting_speed > 0 and
		arena_size.x > 0 and arena_size.y > 0 and
		max_enemies > 0 and
		target_fps > 0
	)

## Get player experience requirement for level
func get_experience_for_level(level: int) -> int:
	if level <= 1:
		return 0
	
	var total_experience: int = 0
	for i in range(2, level + 1):
		var level_requirement = int(base_experience_to_level * pow(experience_scaling_factor, i - 2))
		total_experience += level_requirement
	
	return total_experience

## Get wave for current game time or loop count
func get_wave_for_time(game_time: float, loop_count: int = 0) -> WaveConfiguration:
	if waves.is_empty():
		return null
	
	# Simple sequential wave system for now
	var wave_index = int(game_time / 60.0) % waves.size()  # New wave every minute
	return waves[wave_index]

## Calculate difficulty multiplier for current state
func get_difficulty_multiplier(level: int, loop_count: int = 0) -> float:
	var level_multiplier = pow(difficulty_curve_steepness, level - 1)
	var loop_multiplier = 1.0 + (wave_difficulty_increase * loop_count)
	return level_multiplier * loop_multiplier