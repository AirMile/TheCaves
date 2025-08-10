## IMoveable Interface Documentation
## This is a documentation-only file describing the IMoveable contract
## Godot uses duck typing - just implement these methods in your classes

## SIGNALS TO IMPLEMENT:
## signal movement_started(direction: Vector2)       # When movement begins
## signal movement_stopped                           # When movement stops
## signal target_reached(target: Vector2)           # When reaching target
## signal speed_changed(new_speed: float)           # When speed changes

## METHODS TO IMPLEMENT:
## func set_movement_direction(direction: Vector2) -> void
## func get_movement_direction() -> Vector2
## func set_movement_speed(speed: float) -> void
## func get_movement_speed() -> float
## func move_to_target(target: Vector2) -> void
## func stop_movement() -> void
## func is_moving() -> bool
## func get_velocity() -> Vector2

## EXAMPLE IMPLEMENTATION:
## 
## extends CharacterBody2D
## 
## signal movement_started(direction: Vector2)
## signal movement_stopped
## signal target_reached(target: Vector2)
## signal speed_changed(new_speed: float)
## 
## @export var base_speed: float = 100.0
## var movement_direction: Vector2 = Vector2.ZERO
## var target_position: Vector2
## var has_target: bool = false
## 
## func set_movement_direction(direction: Vector2) -> void:
##     var was_moving = is_moving()
##     movement_direction = direction.normalized()
##     
##     if not was_moving and is_moving():
##         movement_started.emit(movement_direction)
##     elif was_moving and not is_moving():
##         movement_stopped.emit()
## 
## func get_movement_direction() -> Vector2:
##     return movement_direction
## 
## func set_movement_speed(speed: float) -> void:
##     if speed != base_speed:
##         base_speed = speed
##         speed_changed.emit(base_speed)
## 
## func get_movement_speed() -> float:
##     return base_speed
## 
## func move_to_target(target: Vector2) -> void:
##     target_position = target
##     has_target = true
## 
## func stop_movement() -> void:
##     set_movement_direction(Vector2.ZERO)
##     has_target = false
## 
## func is_moving() -> bool:
##     return movement_direction.length() > 0.01
## 
## func get_velocity() -> Vector2:
##     return velocity  # CharacterBody2D built-in property