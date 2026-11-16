extends CanvasLayer

signal mother_interaction_finished

var mother_interaction_completed: bool = false

func complete_mother_interaction() -> void:
	mother_interaction_completed = true
	mother_interaction_finished.emit()
