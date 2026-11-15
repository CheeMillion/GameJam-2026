extends Node
## Autoload named "SFX" (Project Settings > Globals > Autoload).
##
## Drop sound files (.ogg / .wav / .mp3) anywhere inside SFX_FOLDER (subfolders OK).
## The file name (no extension, lowercase) is the sound's name:
##     door_open.wav   ->  SFX.play("door_open")
##
## USAGE:
##   SFX.play("door_open")
##   SFX.play("footstep", -6.0, 0.1)     # quieter (-6 dB) + random pitch wobble (+-10%)
##   SFX.play_music("kitchen_theme")     # crossfades from whatever is playing
##   SFX.stop_music(1.0)                 # fade out over 1 second

const SFX_FOLDER := "res://assets/audio"
const POOL_SIZE := 8   # how many sounds can overlap at once
const EXTENSIONS := ["ogg", "wav", "mp3"]

var _files := {}   # "door_open" -> "res://assets/audio/sfx/door_open.wav"
var _pool: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _music_name := ""
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS   # keeps working while the game is paused
	_scan(SFX_FOLDER)
	for i in POOL_SIZE:
		var p := AudioStreamPlayer.new()
		add_child(p)
		_pool.append(p)
	_music = AudioStreamPlayer.new()
	add_child(_music)


func _scan(folder: String) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		push_warning("SFX: can't open SFX_FOLDER: " + folder)
		return
	for sub in dir.get_directories():
		_scan(folder.path_join(sub))
	for file in dir.get_files():
		# Exported games list "x.wav.import" instead of "x.wav", so handle both.
		var fname: String = file.trim_suffix(".import")
		if fname.get_extension().to_lower() in EXTENSIONS:
			var key: String = fname.get_basename().to_lower()
			var full_path: String = folder.path_join(fname)
			if _files.has(key) and _files[key] != full_path:
				push_warning("SFX: two sounds are both named '%s'. Rename one." % key)
			_files[key] = full_path


func _get_stream(sound: String) -> AudioStream:
	var key := sound.to_lower()
	if not _files.has(key):
		push_warning("SFX: no sound named '%s' found in %s" % [key, SFX_FOLDER])
		return null
	return load(_files[key]) as AudioStream


func _free_player() -> AudioStreamPlayer:
	for p in _pool:
		if not p.playing:
			return p
	return _pool[0]   # everything busy: reuse the first one


func music_is(song: String) -> bool:
	return _music_name == song.to_lower()


func has_sound(sound: String) -> bool:
	return _files.has(sound.to_lower())


## Play a one-shot sound effect. base_pitch: 1.0 = normal, 0.7 = deeper, 1.4 = higher.
func play(sound: String, volume_db: float = 0.0, pitch_variation: float = 0.0, base_pitch: float = 1.0) -> void:
	var stream := _get_stream(sound)
	if stream == null:
		return
	var player := _free_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = base_pitch + randf_range(-pitch_variation, pitch_variation)
	player.play()


## Play looping background music, crossfading from the current track.
func play_music(song: String, fade: float = 0.5, volume_db: float = 0.0) -> void:
	if song.to_lower() == _music_name:
		return
	var stream := _get_stream(song)
	if stream == null:
		return
	if stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.set("loop", true)
	_music_name = song.to_lower()
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	if _music.playing:
		_music_tween.tween_property(_music, "volume_db", -60.0, fade)
	_music_tween.tween_callback(func():
		_music.stream = stream
		_music.volume_db = -60.0
		_music.play())
	_music_tween.tween_property(_music, "volume_db", volume_db, fade)


func stop_music(fade: float = 0.5) -> void:
	_music_name = ""
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(_music, "volume_db", -60.0, fade)
	_music_tween.tween_callback(_music.stop)
