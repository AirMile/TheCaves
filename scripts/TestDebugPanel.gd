extends Control
## Debug panel for test arena

@onready var fps_label: Label = $VBox/FPS
@onready var enemies_label: Label = $VBox/Enemies  
@onready var collision_pairs_label: Label = $VBox/CollisionPairs

func _ready():
	visible = false

func _process(_delta):
	if Input.is_action_just_pressed("debug_toggle"):  # F3
		visible = !visible
	
	if visible:
		_update_debug_info()

func _update_debug_info():
	# Update FPS
	if fps_label:
		fps_label.text = "FPS: %d" % Engine.get_frames_per_second()
	
	# Update enemy count
	if enemies_label and EnemyPool:
		enemies_label.text = "Enemies: %d" % EnemyPool.get_active_count()
	
	# Update collision pairs
	if collision_pairs_label:
		var pairs = Performance.get_monitor(Performance.PHYSICS_2D_COLLISION_PAIRS)
		collision_pairs_label.text = "Collision Pairs: %d" % pairs
		
		# Warning color if too many pairs
		if pairs > 1000:
			collision_pairs_label.modulate = Color.RED
		else:
			collision_pairs_label.modulate = Color.WHITE