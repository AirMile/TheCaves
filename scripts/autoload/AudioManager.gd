extends Node
## High-performance audio system with pooled AudioStreamPlayer2D instances
## Manages 20 audio players to prevent audio stuttering and allocation spikes

const AUDIO_POOL_SIZE: int = 20

# Audio pools
var audio_players: Array[AudioStreamPlayer2D] = []
var available_players: Array[AudioStreamPlayer2D] = []

# Audio resources (placeholder system until actual audio files exist)
var audio_cache: Dictionary = {}

# Performance tracking
var peak_concurrent_sounds: int = 0
var audio_requests_dropped: int = 0

func _ready():
	_initialize_audio_pool()
	_load_placeholder_sounds()

func _initialize_audio_pool():
	print("AudioManager: Initializing %d audio players" % AUDIO_POOL_SIZE)
	
	for i in AUDIO_POOL_SIZE:
		var player = AudioStreamPlayer2D.new()
		player.name = "AudioPlayer" + str(i)
		
		# Configure for performance
		player.max_distance = 1000.0
		player.attenuation = 1.0
		player.set_stream_paused(false)
		
		# Connect finished signal for auto-return
		player.connect("finished", _on_audio_finished.bind(player))
		
		add_child(player)
		audio_players.append(player)
		available_players.append(player)

func _load_placeholder_sounds():
	# In production, this would load actual .ogg files
	# For now, create placeholder AudioStreamGenerator instances
	var placeholder_stream = AudioStreamGenerator.new()
	placeholder_stream.mix_rate = 22050.0
	placeholder_stream.buffer_length = 0.1
	
	# Common game sounds
	audio_cache["shoot"] = placeholder_stream
	audio_cache["enemy_hit"] = placeholder_stream
	audio_cache["enemy_death"] = placeholder_stream
	audio_cache["player_hit"] = placeholder_stream  
	audio_cache["level_up"] = placeholder_stream
	audio_cache["dash"] = placeholder_stream
	audio_cache["pickup"] = placeholder_stream
	
	print("AudioManager: Loaded %d placeholder sound effects" % audio_cache.size())

func play_sound(sound_name: String, position: Vector2 = Vector2.ZERO, volume: float = 0.0, pitch: float = 1.0) -> bool:
	if not sound_name in audio_cache:
		push_warning("AudioManager: Unknown sound: " + sound_name)
		return false
	
	var player = _get_available_player()
	if not player:
		audio_requests_dropped += 1
		if EventBus:
			EventBus.emit_performance_warning_if(true, "AudioManager", "dropped_requests", audio_requests_dropped)
		return false
	
	# Configure player
	player.stream = audio_cache[sound_name]
	player.global_position = position
	player.volume_db = volume
	player.pitch_scale = clampf(pitch, 0.1, 3.0)  # Prevent extreme pitch values
	
	# Play sound
	player.play()
	
	# Track peak usage
	var active_count = AUDIO_POOL_SIZE - available_players.size()
	peak_concurrent_sounds = max(peak_concurrent_sounds, active_count)
	
	return true

func _get_available_player() -> AudioStreamPlayer2D:
	if available_players.is_empty():
		return null
	
	return available_players.pop_back()

func _on_audio_finished(player: AudioStreamPlayer2D):
	if is_instance_valid(player) and player not in available_players:
		available_players.append(player)

# Convenience functions for common game sounds
func play_weapon_fire(position: Vector2):
	play_sound("shoot", position, -5.0, randf_range(0.9, 1.1))

func play_enemy_hit(position: Vector2):  
	play_sound("enemy_hit", position, -3.0, randf_range(0.8, 1.2))

func play_enemy_death(position: Vector2):
	play_sound("enemy_death", position, 0.0, randf_range(0.7, 1.0))

func play_player_hit(position: Vector2):
	play_sound("player_hit", position, 2.0)

func play_level_up(position: Vector2):
	play_sound("level_up", position, 3.0)

func play_dash(position: Vector2):
	play_sound("dash", position, -2.0, 1.3)

func play_pickup(position: Vector2):
	play_sound("pickup", position, -8.0, randf_range(1.0, 1.5))

# Performance monitoring
func get_active_audio_count() -> int:
	return AUDIO_POOL_SIZE - available_players.size()

func get_peak_concurrent_sounds() -> int:
	return peak_concurrent_sounds

func get_dropped_requests_count() -> int:
	return audio_requests_dropped

func get_audio_stats() -> Dictionary:
	return {
		"total_players": AUDIO_POOL_SIZE,
		"active": get_active_audio_count(),
		"available": available_players.size(),
		"peak_concurrent": peak_concurrent_sounds,
		"dropped_requests": audio_requests_dropped
	}

# Stop all audio (for pause/game over scenarios)
func stop_all_audio():
	for player in audio_players:
		if player.playing:
			player.stop()
	
	# Reset available pool
	available_players.clear()
	available_players.append_array(audio_players)