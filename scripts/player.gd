extends CharacterBody2D


@export var SPEED = 300.0
var current_speed = SPEED

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
func _ready() -> void:       # NEW: a label so the zone can recognize the player
	add_to_group("player")

func _physics_process(_delta: float) -> void:

	process_movement()
	move_and_slide()
	
func process_movement() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	
	velocity = direction * current_speed
		
	play_animation(direction)
	
func play_animation(dir: Vector2) -> void:
	if dir.x > 0:
		animated_sprite_2d.play("right")
	elif dir.y < 0:
		animated_sprite_2d.play("up")
	elif dir.y > 0:
		animated_sprite_2d.play("down")
	elif dir.x < 0:
		animated_sprite_2d.play("left")
	else:
		animated_sprite_2d.play("idle")
