extends CanvasLayer

signal finished

@onready var panel: Control = $Panel
@onready var speaker_label: Label = $Panel/Speaker
@onready var text_label: Label = $Panel/Text

var lines: Array = []
var index := 0
var active := false

func _ready() -> void:
	panel.visible = false

func play(new_lines: Array) -> void:
	lines = new_lines
	index = 0
	active = true
	panel.visible = true
	_show_line()
	await finished

func _show_line() -> void:
	speaker_label.text = lines[index]["speaker"]
	text_label.text = lines[index]["text"]

func _unhandled_input(event: InputEvent) -> void:
	if not active:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		index += 1
		if index < lines.size():
			_show_line()
		else:
			active = false
			panel.visible = false
			finished.emit()
