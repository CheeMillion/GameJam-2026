class_name Interactable
extends Area2D
## Put this on an Area2D with a CollisionShape2D, as a child of your furniture/NPC.
## Fill in "lines" in the Inspector. Each entry = one text box.
##
## Line tips:   [sad] text         -> change emotion
##              [dad:angry] text   -> change speaker + emotion

@export var lines: Array[String] = ["It's a thing."]
## Optional: shown on every interaction after the first.
@export var repeat_lines: Array[String] = []
## Optional dialogue to use after the kitchen conversation has happened.
@export var after_mother_lines: Array[String] = []

## Which dialogue box design to use.
@export_enum("Box 1:1", "Box 2:2", "Box 3:3", "Box 4:4") var box_style: int = 1

## Who is talking (picks the portrait). Choose "none" for furniture.
## To add a new character, add their name to this list (lowercase, same as the filename).
@export_enum("none", "mom", "dad", "daniel", "mae", "princess") var speaker: String = "none"

var _interacted_before := false


func interact() -> void:
	var who := "" if speaker == "none" else speaker
	if not after_mother_lines.is_empty() and GameManager.mother_interaction_completed:
		DialogueManager.start(after_mother_lines, box_style, who)
	elif _interacted_before and not repeat_lines.is_empty():
		DialogueManager.start(repeat_lines, box_style, who)
	else:
		DialogueManager.start(lines, box_style, who)
	_interacted_before = true
