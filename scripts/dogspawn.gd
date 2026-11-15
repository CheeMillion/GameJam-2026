extends Area2D

@export var dog_scene: PackedScene

var dog_spawned := false

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("player") and not dog_spawned:

		print("Player detected!")

		dog_spawned = true

		if dog_scene == null:
			print("ERROR: Dog scene is not assigned!")
			return

		var dog = dog_scene.instantiate()

		get_tree().current_scene.add_child(dog)

		dog.global_position = body.global_position + Vector2(80, 0)
		dog.player = body
		dog.show()
		dog.z_index = 10

		print("Dog instantiated!")
		print("Dog position: ", dog.global_position)
		print("Dog visible: ", dog.visible)
