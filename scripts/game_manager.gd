extends CanvasLayer

signal mother_interaction_finished
signal family_interactions_finished

var mother_interaction_completed: bool = false
var father_interaction_completed: bool = false

func complete_mother_interaction() -> void:
	if mother_interaction_completed:
		return
	mother_interaction_completed = true
	mother_interaction_finished.emit()
	_check_family_interactions_finished()

func complete_father_interaction() -> void:
	if father_interaction_completed:
		return
	father_interaction_completed = true
	_check_family_interactions_finished()

func _check_family_interactions_finished() -> void:
	if mother_interaction_completed and father_interaction_completed:
		family_interactions_finished.emit()
