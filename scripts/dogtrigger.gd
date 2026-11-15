extends Area2D

@export var dog: CharacterBody2D


func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	if not is_instance_valid(dog):
		return   # the dog is gone, so there's nothing to tell
	dog.player = body
	print("Dog is now following the player!")
