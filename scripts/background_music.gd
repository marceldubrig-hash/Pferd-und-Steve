extends Node

const BACKGROUND_MUSIC_PATH := "res://assets/audio/background_music_v01.ogg"
const BACKGROUND_VOLUME_DB := -8.0

var music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Do not resolve imported audio while Godot is still opening the project in
	# editor/import mode. On a fresh checkout the .ogg importer may not have
	# produced its resource metadata yet, which makes preload() fail at parse time.
	if Engine.is_editor_hint():
		return

	call_deferred("_start_music")


func _start_music() -> void:
	if music_player != null:
		return

	var background_music := load(BACKGROUND_MUSIC_PATH) as AudioStream
	if background_music == null:
		push_error("Background music could not be loaded: %s" % BACKGROUND_MUSIC_PATH)
		return

	if background_music is AudioStreamOggVorbis:
		(background_music as AudioStreamOggVorbis).loop = true

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.stream = background_music
	music_player.volume_db = BACKGROUND_VOLUME_DB
	add_child(music_player)
	music_player.play()
