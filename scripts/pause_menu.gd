extends CanvasLayer

@onready var overlay: Control = $Overlay
@onready var continue_button: TextureButton = $Overlay/MenuPanel/Continue
@onready var quit_button: TextureButton = $Overlay/MenuPanel/QuitToMenu


func _ready() -> void:
	overlay.hide()
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	continue_button.pressed.connect(_resume_game)
	quit_button.pressed.connect(_quit_to_menu)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if overlay.visible:
			_resume_game()
		else:
			_pause_game()
		get_viewport().set_input_as_handled()


func _pause_game() -> void:
	overlay.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_set_player_movement_enabled(false)
	get_tree().paused = true


func _resume_game() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	_set_player_movement_enabled(true)
	overlay.visible = false


func _quit_to_menu() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _set_player_movement_enabled(enabled: bool) -> void:
	for player in get_tree().get_nodes_in_group("player"):
		if player is CharacterBody2D:
			if not enabled:
				player.velocity = Vector2.ZERO
			player.set_physics_process(enabled)
