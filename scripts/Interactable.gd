class_name Interactable
extends Area2D
## Put this on an Area2D with a CollisionShape2D, as a child of your furniture/item.
## Fill in "lines" in the Inspector. Each entry = one text box.

@export var lines: Array[String] = ["It's a thing."]
## Optional: shown on every interaction after the first.
@export var repeat_lines: Array[String] = []

var _interacted_before := false


func interact() -> void:
	if _interacted_before and not repeat_lines.is_empty():
		DialogueManager.start(repeat_lines)
	else:
		DialogueManager.start(lines)
	_interacted_before = true
