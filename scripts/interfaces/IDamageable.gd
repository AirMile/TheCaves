## IDamageable Interface Documentation
## This is a documentation-only file describing the IDamageable contract
## Godot uses duck typing - just implement these methods in your classes

## SIGNALS TO IMPLEMENT:
## signal damage_taken(amount: int, source: Node2D)  # When entity takes damage
## signal healed(amount: int)                        # When entity is healed  
## signal died                                       # When entity dies
## signal health_changed(current: int, max: int)     # When health changes

## METHODS TO IMPLEMENT:
## func take_damage(amount: int, source: Node2D = null) -> void
## func heal(amount: int) -> void  
## func get_current_health() -> int
## func get_max_health() -> int
## func is_dead() -> bool
## func get_health_percentage() -> float

## EXAMPLE IMPLEMENTATION:
## 
## extends CharacterBody2D
## 
## signal damage_taken(amount: int, source: Node2D)
## signal healed(amount: int)
## signal died
## signal health_changed(current: int, max: int)
## 
## @export var max_health: int = 100
## var current_health: int
## 
## func _ready():
##     current_health = max_health
## 
## func take_damage(amount: int, source: Node2D = null) -> void:
##     current_health = max(0, current_health - amount)
##     damage_taken.emit(amount, source)
##     health_changed.emit(current_health, max_health)
##     if current_health <= 0:
##         died.emit()
## 
## func heal(amount: int) -> void:
##     var old_health = current_health
##     current_health = min(max_health, current_health + amount)
##     if current_health > old_health:
##         healed.emit(amount)
##         health_changed.emit(current_health, max_health)
## 
## func get_current_health() -> int:
##     return current_health
## 
## func get_max_health() -> int:
##     return max_health
## 
## func is_dead() -> bool:
##     return current_health <= 0
## 
## func get_health_percentage() -> float:
##     if max_health <= 0:
##         return 0.0
##     return float(current_health) / float(max_health)