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
		_set_interaction_prompt(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		_set_interaction_prompt(false)
		zoom_view.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		if zoom_view.visible:
			zoom_view.visible = false
		elif player_nearby:
			zoom_view.visible = true

func _set_interaction_prompt(nearby: bool) -> void:
	for prompt in get_tree().get_nodes_in_group("interaction_prompt"):
		prompt.set_object_nearby(self, nearby)
