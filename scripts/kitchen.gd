extends Area2D

const LINES := [
	{"speaker": "Kalihim", "text": "Anak, kain na. Don't stay up so late again, ha?"},
	{"speaker": "Monay", "text": "Opo, Ma. I already reviewed for the quiz."},
]

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.mother_interaction_completed:
		return
	body.can_move = false
	await get_tree().create_timer(0.6).timeout   # let the fade finish first
	await Dialogue.play(LINES)
	body.can_move = true
	GameManager.complete_mother_interaction()
