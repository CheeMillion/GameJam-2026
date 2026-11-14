extends Area2D

# Drag your Bedroom's "dining" marker node into this slot via the Game scene Inspector
@export var bedroom_destination_marker: Marker2D 

# Drag the main room nodes here to switch visibility
@export var bedroom_node: Node2D
@export var dining_room_node: Node2D

func _on_body_entered(body: Node2D) -> void:
	# Verifies the lowercase physics identity of your player character
	if body.name == "player": 
		if bedroom_destination_marker:
			# Shift player coordinates back to the bedroom marker
			body.global_position = bedroom_destination_marker.global_position
			
			# Swap environment visibility
			if bedroom_node and dining_room_node:
				bedroom_node.show()
				dining_room_node.hide()
		else:
			print("Error: bedroom_destination_marker is unassigned in the Inspector!")
