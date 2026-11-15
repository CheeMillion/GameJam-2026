extends CharacterBody2D

@export var SPEED := 400.0
@export var FOLLOW_DISTANCE := 50.0

var player: Node2D = null

func _ready():
	# Start off playing the animation
	$sprite.play("run")

func _physics_process(_delta):
	# If no player has entered the trigger yet, stay idle
	if player == null:
		velocity = Vector2.ZERO
		$sprite.stop() 
		return

	# Calculate how far away the player is
	var distance = global_position.distance_to(player.global_position)

	if distance > FOLLOW_DISTANCE:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		
		# Flip the sprite left or right based on movement direction
		if direction.x != 0:
			$sprite.flip_h = direction.x < 0
		
		# Make sure running animation plays while moving
		if not $sprite.is_playing():
			$sprite.play("run")
	else:
		# Stop moving and look idle once close enough to player
		velocity = Vector2.ZERO
		$sprite.stop() 

	move_and_slide()
