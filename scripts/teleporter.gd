extends Area2D

var busy := false

func _on_body_entered(body: Node2D) -> void:
	if busy or not body.is_in_group("player"):
		return
	busy = true
	var dest: Vector2 = $DestinationPoint.global_position
	await Fade.travel(func(): body.global_position = dest)
	busy = false
