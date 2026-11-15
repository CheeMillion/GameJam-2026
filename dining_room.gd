extends Node2D

@onready var food = $Food
@onready var teleporter_barrier: StaticBody2D = $TeleporterBarrier

func _ready() -> void:
	food.visible = GameManager.mother_interaction_completed
	GameManager.mother_interaction_finished.connect(_show_breakfast)
	if GameManager.mother_interaction_completed and GameManager.father_interaction_completed:
		teleporter_barrier.queue_free()
	else:
		GameManager.family_interactions_finished.connect(_remove_teleporter_barrier)

func _show_breakfast() -> void:
	food.visible = true

func _remove_teleporter_barrier() -> void:
	if is_instance_valid(teleporter_barrier):
		teleporter_barrier.queue_free()
