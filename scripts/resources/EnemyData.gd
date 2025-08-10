class_name EnemyData
extends Resource
## Resource for enemy configuration data
## Makes enemies data-driven instead of hardcoded

## Enemy identification
@export var enemy_id: String = ""
@export var display_name: String = ""
@export var description: String = ""

## Visual properties
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2.ONE
@export var sprite_color: Color = Color.WHITE
@export var collision_size: Vector2 = Vector2(16, 16)

## Health properties
@export var max_health: int = 50
@export var health_regeneration: float = 0.0

## Movement properties
@export var base_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 500.0

## AI properties
@export var ai_type: String = "chase_player"
@export var detection_range: float = 200.0
@export var attack_range: float = 32.0
@export var reaction_time: float = 0.1

## Combat properties
@export var damage: int = 10
@export var attack_cooldown: float = 1.0
@export var knockback_strength: float = 100.0

## Spawning properties
@export var spawn_weight: float = 1.0
@export var min_spawn_level: int = 1
@export var max_spawn_level: int = 999

## Experience and rewards
@export var experience_value: int = 10
@export var drop_chance: float = 0.1

## Sound effects
@export var spawn_sound: AudioStream
@export var death_sound: AudioStream
@export var attack_sound: AudioStream

## Status effects immunity
@export var status_immunities: Array[String] = []

## Validate the resource data
func is_valid() -> bool:
	return (
		enemy_id != "" and
		display_name != "" and
		max_health > 0 and
		base_speed > 0 and
		collision_size.x > 0 and
		collision_size.y > 0
	)

## Get debug string
func get_debug_string() -> String:
	return "EnemyData[%s]: HP=%d, Speed=%.1f, Damage=%d" % [
		enemy_id, max_health, base_speed, damage
	]