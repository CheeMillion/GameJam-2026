extends Node2D

@onready var food = $Food

func _ready() -> void:
	food.visible = GameManager.mother_interaction_completed
	GameManager.mother_interaction_finished.connect(_show_breakfast)

func _show_breakfast() -> void:
	food.visible = true
