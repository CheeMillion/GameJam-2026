extends Area2D

var player_nearby := false

func _ready() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if player_nearby and event.is_action_pressed("interact"):
		for mission_log in get_tree().get_nodes_in_group("mission_log"):
			mission_log.set_objective("Go to the kitchen.")
		get_viewport().set_input_as_handled()

func _set_interaction_prompt(nearby: bool) -> void:
	for prompt in get_tree().get_nodes_in_group("interaction_prompt"):
		prompt.set_object_nearby(self, nearby)
