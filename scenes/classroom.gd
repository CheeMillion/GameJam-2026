extends Area2D

const LINES: Array[String] = [
	"[teacher:angry] Monay! Alam mo ba kung anong oras na?",
	"[mc:worried2] Ma'am, I'm so sorry po. Hindi ko po napansin ang oras.",
	"[teacher:angry] Second time mo na itong late this week. Hindi na tama 'yan.",
	"[mc:worried2] Opo, Ma'am. I promise po, hindi na mauulit.",
	"[teacher:neutral] Alam kong masipag ka, pero part din ng pagiging estudyante ang disiplina.",
	"[mc:worried2] Sorry po talaga Ma'am. I'll come earlier next time.",
	"[teacher:neutral] Sige, umupo ka na. Don't be late again, ha?",
	"[mc:worried2] Opo, Ma'am. Thank you po."
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
