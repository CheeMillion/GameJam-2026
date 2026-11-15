extends CanvasLayer

signal dialogue_started
signal dialogue_finished

const BOX_SCENE_PATHS := [
	"res://scenes/my_dialogue_box.tscn",
	"res://scenes/my_dialogue_box2.tscn",
	"res://scenes/my_dialogue_box3.tscn",
	"res://scenes/my_dialogue_box4.tscn",
]

const PORTRAIT_FOLDER := "res://assets/character sprites"  
const DEFAULT_EMOTION := "neutral"
const CHARS_PER_SEC := 30.0
const PREFIX := ""

const VOICE_EVERY_N_CHARS := 2
const VOICE_VOLUME_DB := -6.0
const VOICE_PITCH_VARIATION := 0.08
const VOICE_PITCH := {
	"mom": 1.0,
	"dad": 0.7,
	"daniel": 1.1,
	"mae": 1.3,
	"princess": 1.5,
}

var is_active := false

var _boxes: Array = []
var _labels: Array = []
var _arrows: Array = []
var _portraits: Array = []
var _current := 0

var _lines: Array = []
var _index := 0
var _typing := false
var _start_frame := -1
var _tween: Tween

var _speaker := ""
var _voice := ""
var _voice_pitch := 1.0
var _emotion := DEFAULT_EMOTION
var _portrait_files := {}   # "mom_happy" -> "res://.../mom_happy.png"
var _tag_regex := RegEx.create_from_string("^\\[(?:(\\w+):)?(\\w+)\\]\\s*([\\s\\S]*)$")


func _ready() -> void:
	layer = 100
	_scan_portraits(PORTRAIT_FOLDER)
	for path in BOX_SCENE_PATHS:
		var scene := load(path) as PackedScene
		if scene == null:
			push_error("DialogueManager: couldn't load " + path)
			_boxes.append(null)
			_labels.append(null)
			_arrows.append(null)
			_portraits.append(null)
			continue
		var box: Control = scene.instantiate()
		add_child(box)
		box.hide()
		_boxes.append(box)
		_labels.append(box.get_node_or_null("%Text"))
		_arrows.append(box.get_node_or_null("%Arrow"))
		_portraits.append(box.get_node_or_null("%Portrait"))
		if _labels.back() == null:
			push_error("DialogueManager: " + path + " needs a Label with Unique Name 'Text'.")


func start(lines: Array, box_style: int = 1, speaker: String = "", voice: String = "", voice_pitch: float = 1.0) -> void:
	if is_active or lines.is_empty():
		return
	_current = clampi(box_style - 1, 0, BOX_SCENE_PATHS.size() - 1)
	if _boxes[_current] == null or _labels[_current] == null:
		push_error("DialogueManager: box style %d isn't set up correctly." % box_style)
		return
	_lines = lines
	_index = 0
	_speaker = speaker
	_voice = voice
	_voice_pitch = voice_pitch
	_emotion = DEFAULT_EMOTION
	is_active = true
	_start_frame = Engine.get_process_frames()
	_boxes[_current].show()
	dialogue_started.emit()
	_show_line()


func _show_line() -> void:
	var raw := str(_lines[_index])
	var body := raw
	var m := _tag_regex.search(raw)
	if m:
		if m.get_string(1) != "":
			_speaker = m.get_string(1)
			_voice = ""
		_emotion = m.get_string(2)
		body = m.get_string(3)
	_update_portrait()

	var label: Label = _labels[_current]
	var text := PREFIX + body
	label.text = text
	label.visible_characters = 0
	if _arrows[_current]:
		_arrows[_current].hide()
	_typing = true
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(_on_char_shown, 0, text.length(), text.length() / CHARS_PER_SEC)
	_tween.finished.connect(_on_typing_done)


func _on_char_shown(value) -> void:
	var count: int = int(value)
	var label: Label = _labels[_current]
	if count == label.visible_characters or count < 1 or count > label.text.length():
		return
	label.visible_characters = count
	var ch: String = label.text[count - 1]
	if ch in " .,!?-\n" or count % VOICE_EVERY_N_CHARS != 0:
		return
	var voice: String = _voice if _voice != "" else _speaker.to_lower() + "_voice"
	if not SFX.has_sound(voice):
		voice = "voice_default"
		if not SFX.has_sound(voice):
			return
	var pitch: float = _voice_pitch if _voice != "" else VOICE_PITCH.get(_speaker.to_lower(), 1.0)
	SFX.play(voice, VOICE_VOLUME_DB, VOICE_PITCH_VARIATION, pitch)


func _update_portrait() -> void:
	var portrait: TextureRect = _portraits[_current]
	if portrait == null:
		return
	if _speaker == "":
		portrait.hide()
		return
	var tex := _get_portrait(_speaker, _emotion)
	if tex == null:
		portrait.hide()
	else:
		portrait.texture = tex
		portrait.show()


func _scan_portraits(folder: String) -> void:
	var dir := DirAccess.open(folder)
	if dir == null:
		push_warning("DialogueManager: can't open PORTRAIT_FOLDER: " + folder)
		return
	for sub in dir.get_directories():
		_scan_portraits(folder.path_join(sub))
	for file in dir.get_files():
		var fname: String = file.trim_suffix(".import")
		if fname.get_extension().to_lower() == "png":
			_portrait_files[fname.get_basename().to_lower()] = folder.path_join(fname)


func _get_portrait(who: String, emotion: String) -> Texture2D:
	for e: String in [emotion, DEFAULT_EMOTION]:
		var key: String = (who + "_" + e).to_lower()
		if _portrait_files.has(key):
			return load(_portrait_files[key]) as Texture2D
	push_warning("DialogueManager: no portrait named '%s_%s' found." % [who.to_lower(), emotion.to_lower()])
	return null


func _on_typing_done() -> void:
	_typing = false
	_labels[_current].visible_characters = -1
	if _arrows[_current]:
		_arrows[_current].show()


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
	_boxes[_current].hide()
	dialogue_finished.emit()


func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	if Engine.get_process_frames() == _start_frame:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if _typing:
			_skip_typing()
		else:
			_advance()
	elif event.is_action_pressed("ui_cancel") and _typing:
		get_viewport().set_input_as_handled()
		_skip_typing()
