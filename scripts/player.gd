extends CharacterBody2D

@export var SPEED = 300.0
@export var SPRINT_SPEED = 500.0
@export var birds_eye_zoom := Vector2(0.5, 0.5)
@export var zoom_duration := 0.25
var current_speed = SPEED
var last_dir := "down"
var birds_eye := false
var normal_zoom := Vector2.ONE
var zoom_tween: Tween

const ROOMS := {
	"kitchen": Rect2(4022, -67, 1478, 1026),
	"bedroom": Rect2(273.8, 136.0, 616.1, 492.4),
	"dining_room": Rect2(2464.1, 1251.1, 396.6, 460.9),
}

@export var right_scale := Vector2(0.91, 0.91)
@export var right_idle_scale := Vector2(1.0, 1.0)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	add_to_group("player")
	normal_zoom = camera.zoom
	camera.top_level = true
	camera.position_smoothing_enabled = false
	camera.limit_left = -10000000
	camera.limit_top = -10000000
	camera.limit_right = 10000000
	camera.limit_bottom = 10000000

func _physics_process(_delta: float) -> void:
	var holding_space := Input.is_key_pressed(KEY_SPACE)
	if holding_space != birds_eye:
		birds_eye = holding_space
		set_birds_eye_zoom(birds_eye)

	if birds_eye:
		velocity = Vector2.ZERO
		play_anim("down_idle")
	else:
		process_movement()

	move_and_slide()
	update_camera()

const ROOM_SETTINGS := {
	"kitchen": {"zoom": 0.9, "offset": Vector2(125, 0)},
	"bedroom": {"zoom": 0.68, "offset": Vector2(123, -150)},
	"dining_room": {"zoom": 0.8, "offset": Vector2(62, -220)},
}

const ROOM_MARGIN := 40.0

func update_camera() -> void:
	var target := animated_sprite_2d.global_position
	var target_zoom := normal_zoom

	for room_name in ROOMS:
		var room: Rect2 = ROOMS[room_name]
		if room.grow(ROOM_MARGIN).has_point(global_position):
			var s: Dictionary = ROOM_SETTINGS[room_name]
			target = room.get_center() + s["offset"]
			target_zoom = Vector2(s["zoom"], s["zoom"])
			break

	camera.global_position = target
	if not birds_eye:
		var new_zoom := camera.zoom.lerp(target_zoom, 0.15)
		if new_zoom.x > 0.01 and new_zoom.y > 0.01:
			camera.zoom = new_zoom

func set_birds_eye_zoom(zoom_out: bool) -> void:
	var target_zoom := birds_eye_zoom if zoom_out else normal_zoom
	if zoom_tween:
		zoom_tween.kill()
	zoom_tween = create_tween()
	zoom_tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	zoom_tween.tween_property(camera, "zoom", target_zoom, zoom_duration)

func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	var sprinting := Input.is_action_pressed("sprint")
	current_speed = SPRINT_SPEED if sprinting else SPEED
	velocity = direction * current_speed
	animated_sprite_2d.speed_scale = 1.5 if sprinting else 1.0
	play_animation(direction)

func play_animation(dir: Vector2) -> void:
	if dir == Vector2.ZERO:
		play_anim(last_dir + "_idle")
		return

	if dir.x > 0:
		last_dir = "right"
	elif dir.x < 0:
		last_dir = "left"
	elif dir.y < 0:
		last_dir = "up"
	elif dir.y > 0:
		last_dir = "down"

	play_anim(last_dir)


func play_anim(anim_name: String) -> void:
	if anim_name == "right":
		animated_sprite_2d.scale = right_scale
	elif anim_name == "right_idle":
		animated_sprite_2d.scale = right_idle_scale
	else:
		animated_sprite_2d.scale = Vector2.ONE
	animated_sprite_2d.play(anim_name)
