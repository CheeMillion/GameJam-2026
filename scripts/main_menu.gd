extends Control


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$Buttons/NewGame.pressed.connect(_start_new_game)
	$Buttons/Quit.pressed.connect(_quit_game)
	$Buttons/Credits.pressed.connect(_show_credits)
	$CreditsOverlay/Quit.pressed.connect(_hide_credits)


func _start_new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")



func _quit_game() -> void:
	get_tree().quit()


func _show_credits() -> void:
	$Buttons.hide()
	$CreditsOverlay.show()


func _hide_credits() -> void:
	$CreditsOverlay.hide()
	$Buttons.show()
