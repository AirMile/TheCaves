## ISpawnable Interface Documentation  
## This is a documentation-only file describing the ISpawnable contract
## Godot uses duck typing - just implement these methods in your classes

## SIGNALS TO IMPLEMENT:
## signal spawned(position: Vector2)                # When entity is spawned
## signal despawned                                  # When entity is despawned
## signal return_to_pool_requested                   # When ready for pooling

## METHODS TO IMPLEMENT:
## func spawn_at(position: Vector2, data: Dictionary = {}) -> void
## func despawn() -> void
## func reset_state() -> void
## func is_spawned() -> bool
## func get_spawn_data() -> Dictionary
## func set_spawn_data(data: Dictionary) -> void

## EXAMPLE IMPLEMENTATION:
## 
## extends CharacterBody2D
## 
## signal spawned(position: Vector2)
## signal despawned  
## signal return_to_pool_requested
## 
## var is_active: bool = false
## var spawn_data: Dictionary = {}
## 
## func spawn_at(position: Vector2, data: Dictionary = {}) -> void:
##     global_position = position
##     spawn_data = data
##     is_active = true
##     visible = true
##     set_physics_process(true)
##     set_process(true)
##     spawned.emit(position)
## 
## func despawn() -> void:
##     is_active = false
##     visible = false
##     set_physics_process(false)
##     set_process(false)
##     despawned.emit()
##     return_to_pool_requested.emit()
## 
## func reset_state() -> void:
##     velocity = Vector2.ZERO
##     rotation = 0.0
##     spawn_data.clear()
##     is_active = false
## 
## func is_spawned() -> bool:
##     return is_active
## 
## func get_spawn_data() -> Dictionary:
##     return spawn_data.duplicate()
## 
## func set_spawn_data(data: Dictionary) -> void:
##     spawn_data = data