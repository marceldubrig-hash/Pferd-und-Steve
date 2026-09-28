extends Node

const BACKGROUND_MUSIC := preload("res://assets/audio/background_music_v01.ogg")
const BACKGROUND_VOLUME_DB := -8.0

var music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	if BACKGROUND_MUSIC is AudioStreamOggVorbis:
		BACKGROUND_MUSIC.loop = true

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.stream = BACKGROUND_MUSIC
	music_player.volume_db = BACKGROUND_VOLUME_DB
	add_child(music_player)
	music_player.play()
