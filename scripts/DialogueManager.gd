extends CanvasLayer
## Autoload this as "DialogueManager" (Project Settings > Globals > Autoload).
## Builds its own placeholder UI in code, so no scene setup is needed.

signal dialogue_started
signal dialogue_finished

const CHARS_PER_SEC := 30.0
const PREFIX := "* "   # Undertale-style bullet. Set to "" to disable.

var is_active := false

var _lines: Array = []
var _index := 0
var _typing := false
var _start_frame := -1
var _tween: Tween
var _panel: Panel
var _label: Label
var _arrow: Label


func _ready() -> void:
	layer = 100
	_build_ui()
	_panel.hide()


func _build_ui() -> void:
	_panel = Panel.new()
	var style := StyleBoxFlat.new()
	style.bg_color = Color.BLACK
	style.border_color = Color.WHITE
	style.set_border_width_all(4)
	_panel.add_theme_stylebox_override("panel", style)
	_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_panel.offset_left = 40
	_panel.offset_right = -40
	_panel.offset_top = -170
	_panel.offset_bottom = -20
	add_child(_panel)

	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.offset_left = 20
	_label.offset_top = 14
	_label.offset_right = -20
	_label.offset_bottom = -14
	_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_label.add_theme_font_size_override("font_size", 28)
	_panel.add_child(_label)

	_arrow = Label.new()
	_arrow.text = "v"
	_arrow.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_arrow.offset_left = -40
	_arrow.offset_top = -40
	_arrow.offset_right = -14
	_arrow.offset_bottom = -8
	_arrow.add_theme_font_size_override("font_size", 24)
	_panel.add_child(_arrow)


## Pass an Array of Strings. Each string is one text box.
func start(lines: Array) -> void:
	if is_active or lines.is_empty():
		return
	_lines = lines
	_index = 0
	is_active = true
	_start_frame = Engine.get_process_frames()
	_panel.show()
	dialogue_started.emit()
	_show_line()


func _show_line() -> void:
	var text := PREFIX + str(_lines[_index])
	_label.text = text
	_label.visible_characters = 0
	_arrow.hide()
	_typing = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_label, "visible_characters", text.length(), text.length() / CHARS_PER_SEC)
	_tween.finished.connect(_on_typing_done)
	# Hook: play a text blip sound here if you want (per char or per line).


func _on_typing_done() -> void:
	_typing = false
	_label.visible_characters = -1
	_arrow.show()


func _skip_typing() -> void:
	if _tween:
		_tween.kill()
	_on_typing_done()


func _advance() -> void:
	_index += 1
	if _index >= _lines.size():
		_end()
	else:
		_show_line()


func _end() -> void:
	is_active = false
	_panel.hide()
	dialogue_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return
	# Ignore the same keypress that opened the dialogue.
	if Engine.get_process_frames() == _start_frame:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if _typing:
			_skip_typing()
		else:
			_advance()
	elif event.is_action_pressed("ui_cancel") and _typing:  # X to skip text, like Undertale
		get_viewport().set_input_as_handled()
		_skip_typing()
