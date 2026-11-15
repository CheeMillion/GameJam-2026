extends Area2D

@export var song := ""
@export var fade := 0.5
@export var stop_on_exit := true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if song == "":
		SFX.stop_music(fade)
	else:
		SFX.play_music(song, fade)

func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if stop_on_exit and song != "" and SFX.music_is(song):
		SFX.stop_music(fade)
