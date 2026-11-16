extends CanvasLayer

@onready var objective_label: Label = $Panel/MarginContainer/VBoxContainer/Objective

func _ready() -> void:
	add_to_group("mission_log")
	set_objective("Get ready for school: Change clothes in the closet")

func set_objective(text: String) -> void:
	objective_label.text = text
