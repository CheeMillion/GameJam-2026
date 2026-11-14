extends Control

const PHONE_WIDTH_RATIO := 0.25
const PHONE_ASPECT_RATIO := 520.0 / 1000.0
const SIDE_MARGIN := 24.0
const BOTTOM_MARGIN := 16.0
const SLIDE_DURATION := 0.35

@onready var phone: Control = $Phone
@onready var screen_background: TextureRect = $Phone/ScreenBackground
@onready var device_frame: TextureRect = $Phone/DeviceFrame

var is_open := false
var slide_tween: Tween


func _ready() -> void:
	get_viewport().size_changed.connect(_layout_phone)
	_layout_phone()
	phone.position.y = get_viewport_rect().size.y + 8.0


func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_E:
		is_open = not is_open
		_slide_phone()
		get_viewport().set_input_as_handled()


func _layout_phone() -> void:
	var viewport_size := get_viewport_rect().size
	var phone_size := Vector2(viewport_size.x * PHONE_WIDTH_RATIO, viewport_size.x * PHONE_WIDTH_RATIO / PHONE_ASPECT_RATIO)
	var max_height := viewport_size.y - BOTTOM_MARGIN * 2.0
	if phone_size.y > max_height:
		phone_size.y = max_height
		phone_size.x = phone_size.y * PHONE_ASPECT_RATIO

	phone.size = phone_size
	phone.position.x = SIDE_MARGIN
	var scale_factor := phone_size.x / 520.0
	screen_background.position = Vector2(25.0, 36.0) * scale_factor
	screen_background.size = Vector2(470.0, 928.0) * scale_factor
	device_frame.position = Vector2.ZERO
	device_frame.size = phone_size

	if is_open:
		phone.position.y = viewport_size.y - phone_size.y - BOTTOM_MARGIN
	else:
		phone.position.y = viewport_size.y + 8.0


func _slide_phone() -> void:
	if slide_tween and slide_tween.is_running():
		slide_tween.kill()

	var viewport_size := get_viewport_rect().size
	var target_y := viewport_size.y - phone.size.y - BOTTOM_MARGIN if is_open else viewport_size.y + 8.0
	slide_tween = create_tween()
	slide_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	slide_tween.tween_property(phone, "position:y", target_y, SLIDE_DURATION)
