extends Node2D

@export var map_left := 6802
@export var map_top := 65
@export var map_right := 10642
@export var map_bottom := 2200

func _ready() -> void:
	call_deferred("setup_camera")

func setup_camera() -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var cam: Camera2D = player.get_node("Camera2D")
	cam.limit_left = map_left
	cam.limit_top = map_top
	cam.limit_right = map_right
	cam.limit_bottom = map_bottom
	cam.reset_smoothing()
	print("Player position: ", player.global_position)
	print("Map bounds: ", map_left, ", ", map_top, " to ", map_right, ", ", map_bottom)
