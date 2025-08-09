class_name UIManager
extends CanvasLayer
## Manages all UI elements and user interface interactions
## Follows single responsibility principle for UI management

## UI element references
@onready var game_ui_container: VBoxContainer = $GameUI
@onready var enemy_counter_label: Label = $GameUI/EnemyCounter
@onready var controls_label: Label = $GameUI/Controls
@onready var debug_panel: Control = $DebugPanel
@onready var debug_info_labels: Dictionary = {}

## UI state
var is_debug_visible: bool = false
var current_ui_mode: String = "game"

## Game data for display
var current_enemies: int = 0
var max_enemies: int = 5
var player_health: int = 100
var player_max_health: int = 100
var player_level: int = 1
var game_time: float = 0.0

func _ready() -> void:
	add_to_group("ui_managers")
	_setup_ui_elements()
	_connect_to_event_bus()
	_setup_debug_panel()
	
	print("UIManager initialized")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle"):
		toggle_debug_panel()

## Setup initial UI elements
func _setup_ui_elements() -> void:
	if not game_ui_container:
		push_error("UIManager: GameUI container not found")
		return
	
	# Setup game UI
	if enemy_counter_label:
		enemy_counter_label.text = "Enemies: 0/5"
	
	if controls_label:
		controls_label.text = "WASD = Move, F3 = Debug"

## Setup debug panel elements
func _setup_debug_panel() -> void:
	if not debug_panel:
		push_warning("UIManager: Debug panel not found, creating basic one")
		_create_debug_panel()
		return
	
	# Hide debug panel initially
	debug_panel.visible = false
	
	# Find or create debug labels
	var vbox = debug_panel.get_node_or_null("VBox")
	if vbox:
		for child in vbox.get_children():
			if child is Label:
				debug_info_labels[child.name] = child

## Create basic debug panel if not found in scene
func _create_debug_panel() -> void:
	debug_panel = Control.new()
	debug_panel.name = "DebugPanel"
	debug_panel.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
	debug_panel.position = Vector2(10, -120)
	debug_panel.size = Vector2(300, 110)
	debug_panel.visible = false
	add_child(debug_panel)
	
	var vbox = VBoxContainer.new()
	vbox.name = "VBox"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	debug_panel.add_child(vbox)
	
	# Create debug labels
	var debug_labels = ["FPS", "Enemies", "Health", "Level", "Time"]
	for label_name in debug_labels:
		var label = Label.new()
		label.name = label_name
		label.text = "%s: 0" % label_name
		vbox.add_child(label)
		debug_info_labels[label_name] = label

## Connect to EventBus signals
func _connect_to_event_bus() -> void:
	if not EventBus:
		push_error("UIManager: EventBus autoload not found")
		return
	
	# Connect to UI-relevant signals
	EventBus.player_health_changed.connect(_on_player_health_changed)
	EventBus.player_leveled_up.connect(_on_player_leveled_up)
	EventBus.enemy_spawned.connect(_on_enemy_spawned)
	EventBus.enemy_despawned.connect(_on_enemy_despawned)
	EventBus.wave_progress_updated.connect(_on_wave_progress_updated)
	EventBus.game_state_changed.connect(_on_game_state_changed)
	EventBus.fps_changed.connect(_on_fps_changed)

## Toggle debug panel visibility
func toggle_debug_panel() -> void:
	is_debug_visible = not is_debug_visible
	if debug_panel:
		debug_panel.visible = is_debug_visible
	
	if is_debug_visible:
		EventBus.set_debug_enabled(true)
	else:
		EventBus.set_debug_enabled(false)
	
	print("UIManager: Debug panel %s" % ("shown" if is_debug_visible else "hidden"))

## Update game UI elements
func update_game_ui() -> void:
	if enemy_counter_label:
		enemy_counter_label.text = "Enemies: %d/%d" % [current_enemies, max_enemies]

## Update debug panel information
func update_debug_panel(delta: float) -> void:
	if not is_debug_visible or debug_info_labels.is_empty():
		return
	
	game_time += delta
	
	# Update debug labels
	if "FPS" in debug_info_labels:
		debug_info_labels["FPS"].text = "FPS: %d" % Engine.get_frames_per_second()
	
	if "Enemies" in debug_info_labels:
		debug_info_labels["Enemies"].text = "Enemies: %d" % current_enemies
	
	if "Health" in debug_info_labels:
		debug_info_labels["Health"].text = "Health: %d/%d" % [player_health, player_max_health]
	
	if "Level" in debug_info_labels:
		debug_info_labels["Level"].text = "Level: %d" % player_level
	
	if "Time" in debug_info_labels:
		debug_info_labels["Time"].text = "Time: %.1fs" % game_time

func _process(delta: float) -> void:
	if is_debug_visible:
		update_debug_panel(delta)

## Show notification message
func show_notification(message: String, type: String = "info", _duration: float = 2.0) -> void:
	print("Notification [%s]: %s" % [type, message])
	# Could create a proper notification system here

## Change UI mode (game, menu, pause, etc.)
func set_ui_mode(mode: String) -> void:
	if current_ui_mode == mode:
		return
	
	current_ui_mode = mode
	print("UIManager: Changed to %s mode" % mode)
	
	# Handle different UI modes
	match mode:
		"game":
			_show_game_ui()
		"menu":
			_show_menu_ui()
		"pause":
			_show_pause_ui()

## Show game UI elements
func _show_game_ui() -> void:
	if game_ui_container:
		game_ui_container.visible = true

## Show menu UI elements
func _show_menu_ui() -> void:
	if game_ui_container:
		game_ui_container.visible = false

## Show pause UI elements
func _show_pause_ui() -> void:
	# Could implement pause menu here
	pass

## Event handlers
func _on_player_health_changed(current: int, maximum: int) -> void:
	player_health = current
	player_max_health = maximum

func _on_player_leveled_up(new_level: int) -> void:
	player_level = new_level
	show_notification("Level Up! Reached level %d" % new_level, "success", 3.0)

func _on_enemy_spawned(_enemy: Node2D, _enemy_data: EnemyData) -> void:
	current_enemies += 1
	update_game_ui()

func _on_enemy_despawned(_enemy: Node2D) -> void:
	current_enemies = max(0, current_enemies - 1)
	update_game_ui()

func _on_wave_progress_updated(enemies_remaining: int, _total_enemies: int) -> void:
	current_enemies = enemies_remaining
	update_game_ui()

func _on_game_state_changed(_old_state: GamePhase.Type, new_state: GamePhase.Type) -> void:
	match new_state:
		GamePhase.Type.PLAYING:
			set_ui_mode("game")
		GamePhase.Type.MENU:
			set_ui_mode("menu")
		GamePhase.Type.PAUSED:
			set_ui_mode("pause")
		GamePhase.Type.GAME_OVER:
			show_notification("Game Over", "error", 5.0)
		GamePhase.Type.VICTORY:
			show_notification("Victory!", "success", 5.0)

func _on_fps_changed(current_fps: int, target_fps: int) -> void:
	if current_fps < target_fps * 0.8:  # 80% of target
		var fps_color = Color.RED if current_fps < target_fps * 0.6 else Color.YELLOW
		if "FPS" in debug_info_labels:
			debug_info_labels["FPS"].modulate = fps_color
	else:
		if "FPS" in debug_info_labels:
			debug_info_labels["FPS"].modulate = Color.WHITE

## Get current UI state for debugging
func get_debug_info() -> Dictionary:
	return {
		"current_mode": current_ui_mode,
		"debug_visible": is_debug_visible,
		"current_enemies": current_enemies,
		"player_health": "%d/%d" % [player_health, player_max_health],
		"player_level": player_level
	}