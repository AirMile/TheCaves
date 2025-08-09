extends Node

# Audio pooling system for performance with 100+ enemies

const AUDIO_POOL_SIZE = 20  # Pool for simultaneous sound effects

var audio_players: Array[AudioStreamPlayer2D] = []
var current_player_index: int = 0

func _ready():
	print("AudioManager initializing...")
	_create_audio_pool()
	print("AudioManager initialized with %d audio players" % AUDIO_POOL_SIZE)

func _create_audio_pool():
	for i in AUDIO_POOL_SIZE:
		var player = AudioStreamPlayer2D.new()
		player.name = "PooledAudio_%d" % i
		add_child(player)
		audio_players.append(player)

func play_sound(stream: AudioStream, position: Vector2 = Vector2.ZERO, volume: float = 0.0):
	if not stream:
		return
		
	var player = _get_next_player()
	player.stream = stream
	player.global_position = position
	player.volume_db = volume
	player.play()

func _get_next_player() -> AudioStreamPlayer2D:
	var player = audio_players[current_player_index]
	current_player_index = (current_player_index + 1) % AUDIO_POOL_SIZE
	return player