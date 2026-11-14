extends Area2D

@export var slow_speed = 100.0
@export var slow_multiplier := 0.4 
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.slow_multiplier = slow_multiplier

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.slow_multiplier = 1.0
