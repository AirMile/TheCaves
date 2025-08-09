extends Node

# Global event bus for decoupled system communication
# Performance-first design - use signals instead of function calls

# Player events
signal player_died
signal player_health_changed(new_health: int)
signal player_level_up
signal player_position_changed(position: Vector2)

# Enemy events  
signal enemy_spawned(enemy: Node2D)
signal enemy_died(enemy: Node2D)
signal enemy_damaged(enemy: Node2D, damage: int)

# Projectile events
signal projectile_fired(projectile: Node2D)
signal projectile_hit(projectile: Node2D, target: Node2D)

# Game events
signal game_paused
signal game_resumed
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)

# UI events
signal debug_panel_toggled(visible: bool)
signal upgrade_selected(upgrade_data: Dictionary)

func _ready():
	print("EventBus initialized")