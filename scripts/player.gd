extends CharacterBody2D

@export var SPEED = 300.0
@export var SPRINT_SPEED = 500.0
var current_speed = SPEED
var last_dir := "down"

@export var right_scale := Vector2(0.91, 0.91)
@export var right_idle_scale := Vector2(1.0, 1.0)

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	process_movement()
	move_and_slide()

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
