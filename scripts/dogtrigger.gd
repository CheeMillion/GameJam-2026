extends Area2D

@export var dog: CharacterBody2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Changed "player" to match your add_to_group("player") call in player.gd
	if body.is_in_group("player"): 
		dog.player = body
		print("Dog is now following the player!")
