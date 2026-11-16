extends Area2D

const LINES: Array[String] = [
	"[mom:neutral] Anak, kain na. Don't stay up so late again, ha?",
	"[mc:happy] Opo, Ma. I already reviewed for the quiz.",
]

const BOX_STYLE := 1   # which dialogue box design (1-4)

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if GameManager.mother_interaction_completed:
		return
	body.can_move = false
	await get_tree().create_timer(0.6).timeout   # let the fade finish first
	DialogueManager.start(LINES, BOX_STYLE)
	await DialogueManager.dialogue_finished
	body.can_move = true
	GameManager.complete_mother_interaction()
