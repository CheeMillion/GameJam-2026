extends Control


func _ready() -> void:
	$Buttons/NewGame.pressed.connect(_start_new_game)
	$Buttons/Quit.pressed.connect(_quit_game)


func _start_new_game() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")



func _quit_game() -> void:
	get_tree().quit()
