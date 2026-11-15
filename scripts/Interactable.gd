class_name Interactable

extends Area2D
@export var voice := ""            # sound file name without extension, e.g. "noel" for noel.wav
@export var voice_pitch := 1.0     # lower = deeper, higher = squeakier

@export var lines: Array[String] = ["It's a thing."]

@export var repeat_lines: Array[String] = []

@export var after_mother_lines: Array[String] = []

@export_enum("Box 1:1", "Box 2:2", "Box 3:3", "Box 4:4") var box_style: int = 1

@export_enum("none", "mom", "dad", "daniel", "mae", "princess") var speaker: String = "none"
## Mark the dad NPC whose conversation should unlock the dining room teleporter.
@export var completes_father_interaction := false

var _interacted_before := false


func interact() -> void:
	if DialogueManager.is_active:
		return
	var who := "" if speaker == "none" else speaker
	if not after_mother_lines.is_empty() and GameManager.mother_interaction_completed:
		DialogueManager.start(after_mother_lines, box_style, who, voice, voice_pitch)
	elif _interacted_before and not repeat_lines.is_empty():
		DialogueManager.start(repeat_lines, box_style, who, voice, voice_pitch)
	else:
		DialogueManager.start(lines, box_style, who, voice, voice_pitch)
	_interacted_before = true
	if completes_father_interaction:
		await DialogueManager.dialogue_finished
		GameManager.complete_father_interaction()
