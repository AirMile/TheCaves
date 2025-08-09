extends Node

const MAX_AUDIO_PLAYERS: int = 20
const MAX_MUSIC_PLAYERS: int = 2

var sfx_players: Array[AudioStreamPlayer] = []
var music_players: Array[AudioStreamPlayer] = []
var available_sfx_players: Array[AudioStreamPlayer] = []
var available_music_players: Array[AudioStreamPlayer] = []

var master_volume: float = 1.0
var sfx_volume: float = 1.0
var music_volume: float = 0.7

var audio_streams: Dictionary = {}

var current_music: AudioStreamPlayer
var music_fade_tween: Tween

func _ready():
	set_process_mode(Node.PROCESS_MODE_ALWAYS)
	
	_initialize_audio_pools()
	_load_audio_streams()
	
	if OS.is_debug_build():
		print("[AudioManager] Initialized - SFX Players: %d, Music Players: %d" % [MAX_AUDIO_PLAYERS, MAX_MUSIC_PLAYERS])

func _initialize_audio_pools():
	for i in MAX_AUDIO_PLAYERS:
		var player = AudioStreamPlayer.new()
		player.name = "SFXPlayer_%d" % i
		add_child(player)
		sfx_players.append(player)
		available_sfx_players.append(player)
		
		player.finished.connect(_on_sfx_player_finished.bind(player))
	
	for i in MAX_MUSIC_PLAYERS:
		var player = AudioStreamPlayer.new()
		player.name = "MusicPlayer_%d" % i
		add_child(player)
		music_players.append(player)
		available_music_players.append(player)
		
		player.finished.connect(_on_music_player_finished.bind(player))

func _load_audio_streams():
	var audio_dir = "res://assets/audio/"
	
	var sfx_sounds = {
		"player_hurt": "sfx/player_hurt.ogg",
		"player_dash": "sfx/player_dash.ogg",
		"enemy_die": "sfx/enemy_die.ogg",
		"weapon_fire": "sfx/weapon_fire.ogg",
		"pickup_exp": "sfx/pickup_exp.ogg",
		"pickup_health": "sfx/pickup_health.ogg",
		"level_up": "sfx/level_up.ogg",
		"wave_complete": "sfx/wave_complete.ogg",
		"button_click": "sfx/button_click.ogg"
	}
	
	var music_tracks = {
		"menu_theme": "music/menu_theme.ogg",
		"game_theme": "music/game_theme.ogg",
		"boss_theme": "music/boss_theme.ogg"
	}
	
	for sound_name in sfx_sounds:
		var path = audio_dir + sfx_sounds[sound_name]
		if ResourceLoader.exists(path):
			audio_streams[sound_name] = load(path)
		elif OS.is_debug_build():
			print("[AudioManager] Warning: Audio file not found: %s" % path)
	
	for track_name in music_tracks:
		var path = audio_dir + music_tracks[track_name]
		if ResourceLoader.exists(path):
			audio_streams[track_name] = load(path)
		elif OS.is_debug_build():
			print("[AudioManager] Warning: Music file not found: %s" % path)

func play_sfx(sound_name: String, volume_db: float = 0.0, pitch_scale: float = 1.0) -> AudioStreamPlayer:
	if not audio_streams.has(sound_name):
		if OS.is_debug_build():
			print("[AudioManager] Warning: Unknown sound: %s" % sound_name)
		return null
	
	var player = _get_available_sfx_player()
	if not player:
		return null
	
	player.stream = audio_streams[sound_name]
	player.volume_db = volume_db + linear_to_db(sfx_volume * master_volume)
	player.pitch_scale = pitch_scale
	player.play()
	
	available_sfx_players.erase(player)
	
	return player

func play_music(track_name: String, fade_in_duration: float = 1.0, loop: bool = true):
	if not audio_streams.has(track_name):
		if OS.is_debug_build():
			print("[AudioManager] Warning: Unknown music track: %s" % track_name)
		return
	
	if current_music and current_music.playing:
		stop_music(fade_in_duration * 0.5)
	
	var player = _get_available_music_player()
	if not player:
		return
	
	player.stream = audio_streams[track_name]
	if player.stream is AudioStreamOggVorbis:
		player.stream.loop = loop
	
	player.volume_db = linear_to_db(0.01)  # Start very quiet
	player.play()
	
	current_music = player
	available_music_players.erase(player)
	
	if music_fade_tween:
		music_fade_tween.kill()
	music_fade_tween = create_tween()
	music_fade_tween.tween_method(
		_set_music_volume_db, 
		linear_to_db(0.01), 
		linear_to_db(music_volume * master_volume),
		fade_in_duration
	)

func stop_music(fade_out_duration: float = 1.0):
	if not current_music or not current_music.playing:
		return
	
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_method(
		_set_music_volume_db,
		current_music.volume_db,
		linear_to_db(0.01),
		fade_out_duration
	)
	music_fade_tween.tween_callback(current_music.stop).set_delay(fade_out_duration)

func _set_music_volume_db(volume_db: float):
	if current_music:
		current_music.volume_db = volume_db

func _get_available_sfx_player() -> AudioStreamPlayer:
	if available_sfx_players.size() > 0:
		return available_sfx_players[0]
	
	for player in sfx_players:
		if not player.playing:
			return player
	
	if OS.is_debug_build():
		print("[AudioManager] Warning: All SFX players busy, interrupting oldest")
	return sfx_players[0]

func _get_available_music_player() -> AudioStreamPlayer:
	if available_music_players.size() > 0:
		return available_music_players[0]
	
	return music_players[0]

func _on_sfx_player_finished(player: AudioStreamPlayer):
	if not available_sfx_players.has(player):
		available_sfx_players.append(player)

func _on_music_player_finished(player: AudioStreamPlayer):
	if player == current_music:
		current_music = null
	if not available_music_players.has(player):
		available_music_players.append(player)

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_all_volumes()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_all_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	_update_all_volumes()

func _update_all_volumes():
	for player in sfx_players:
		if player.playing and player.stream:
			var base_volume = db_to_linear(player.volume_db) / (sfx_volume * master_volume) if sfx_volume * master_volume > 0 else 1.0
			player.volume_db = linear_to_db(base_volume * sfx_volume * master_volume)
	
	if current_music and current_music.playing:
		current_music.volume_db = linear_to_db(music_volume * master_volume)

func stop_all_sfx():
	for player in sfx_players:
		if player.playing:
			player.stop()
			if not available_sfx_players.has(player):
				available_sfx_players.append(player)

func get_audio_stats() -> Dictionary:
	var active_sfx = 0
	var active_music = 0
	
	for player in sfx_players:
		if player.playing:
			active_sfx += 1
	
	for player in music_players:
		if player.playing:
			active_music += 1
	
	return {
		"active_sfx": active_sfx,
		"available_sfx": available_sfx_players.size(),
		"active_music": active_music,
		"available_music": available_music_players.size(),
		"master_volume": master_volume,
		"sfx_volume": sfx_volume,
		"music_volume": music_volume
	}