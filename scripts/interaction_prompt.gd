extends CanvasLayer

@onready var prompt: Control = $Prompt

var nearby_objects: Dictionary = {}

func _ready() -> void:
	add_to_group("interaction_prompt")
	prompt.hide()

func set_object_nearby(object: Object, nearby: bool) -> void:
	var object_id := object.get_instance_id()
	if nearby:
		nearby_objects[object_id] = true
	else:
		nearby_objects.erase(object_id)
	prompt.visible = not nearby_objects.is_empty()
