## IGameState Interface Documentation
## This is a documentation-only file describing the IGameState contract
## Godot uses duck typing - just implement these methods in your classes

## Game state enum - copy this to implementing classes
## enum GamePhase {
##     MENU,
##     LOADING, 
##     PLAYING,
##     PAUSED,
##     GAME_OVER,
##     VICTORY
## }

## SIGNALS TO IMPLEMENT:
## signal state_changed(old_state: GamePhase, new_state: GamePhase)
## signal game_started
## signal game_ended(victory: bool)  
## signal game_paused(paused: bool)

## METHODS TO IMPLEMENT:
## func set_game_state(new_state: GamePhase) -> void
## func get_game_state() -> GamePhase
## func start_game() -> void
## func end_game(victory: bool = false) -> void
## func set_paused(paused: bool) -> void
## func is_paused() -> bool
## func is_playing() -> bool

## EXAMPLE IMPLEMENTATION:
## 
## extends Node
## 
## enum GamePhase {
##     MENU,
##     LOADING,
##     PLAYING, 
##     PAUSED,
##     GAME_OVER,
##     VICTORY
## }
## 
## signal state_changed(old_state: GamePhase, new_state: GamePhase)
## signal game_started
## signal game_ended(victory: bool)
## signal game_paused(paused: bool)
## 
## var current_state: GamePhase = GamePhase.MENU
## var is_game_paused: bool = false
## 
## func set_game_state(new_state: GamePhase) -> void:
##     var old_state = current_state
##     current_state = new_state
##     state_changed.emit(old_state, new_state)
## 
## func get_game_state() -> GamePhase:
##     return current_state
## 
## func start_game() -> void:
##     set_game_state(GamePhase.PLAYING)
##     game_started.emit()
## 
## func end_game(victory: bool = false) -> void:
##     set_game_state(GamePhase.GAME_OVER if not victory else GamePhase.VICTORY)
##     game_ended.emit(victory)
## 
## func set_paused(paused: bool) -> void:
##     is_game_paused = paused
##     get_tree().paused = paused
##     game_paused.emit(paused)
## 
## func is_paused() -> bool:
##     return is_game_paused
## 
## func is_playing() -> bool:
##     return current_state == GamePhase.PLAYING and not is_paused()

# Create global GamePhase enum for use across the project
class_name GamePhase
enum Type {
	MENU,
	LOADING,
	PLAYING,
	PAUSED,
	GAME_OVER,
	VICTORY
}