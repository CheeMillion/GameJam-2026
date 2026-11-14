extends Area2D

@onready var zoom_view: Control = $CanvasLayer/Control

var player_nearby := false

func _ready() -> void:
	print(zoom_view)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		print("Near ")

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		zoom_view.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("player_nearby is: ", player_nearby)
		if zoom_view.visible:
			zoom_view.visible = false
		elif player_nearby:
			zoom_view.visible = true
			print("zoom shown")
