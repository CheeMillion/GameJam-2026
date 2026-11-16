extends Area2D

@export var dog: CharacterBody2D
@export var chase_music := "dog_chase"
@export var fade := 0.5
@export var music_distance := 800.0
@export var buffer := 100.0

var chasing := false
var music_on := false
var player_ref: Node2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if chasing or not body.is_in_group("player"):
		return
	chasing = true
	player_ref = body
	dog.player = body

func _process(_delta: float) -> void:
	if not chasing:
		return
	var distance := dog.global_position.distance_to(player_ref.global_position)
	if not music_on and distance < music_distance:
		music_on = true
		SFX.play_music(chase_music, fade)
	elif music_on and distance > music_distance + buffer:
		music_on = false
		if SFX.music_is(chase_music):
			SFX.stop_music(fade)
