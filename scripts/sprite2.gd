extends Area2D


@export var bedroom_destination_marker: Marker2D 

@export var bedroom_node: Node2D
@export var dining_room_node: Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.name == "player": 
		if bedroom_destination_marker:
			body.global_position = bedroom_destination_marker.global_position
			
			if bedroom_node and dining_room_node:
				bedroom_node.show()
				dining_room_node.hide()
		else:
			print("Error: bedroom_destination_marker is unassigned in the Inspector!")
