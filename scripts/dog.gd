extends CharacterBody2D

@export var SPEED := 400.0
@export var FOLLOW_DISTANCE := 50.0

var player: Node2D = null

const BED_POSITION := Vector2(1021, 257)
const FADE_TIME := 3.0
var caught := false

func _ready():
	$sprite.play("run")
	$Area2D.body_entered.connect(_on_touch_area_body_entered)

func _on_touch_area_body_entered(body):
	if caught or not body.is_in_group("player"):
		return
	caught = true
	player = null            
	body.can_move = false   

	
	var layer := CanvasLayer.new()
	layer.layer = 100       
	var rect := ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0    
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	get_tree().current_scene.add_child(layer)
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var tween := layer.create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, FADE_TIME)
	tween.tween_callback(func():
		body.global_position = BED_POSITION
		hide()               
	)
	tween.tween_property(rect, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(func():
		body.can_move = true
		layer.queue_free()
		queue_free()         
	)

func _physics_process(_delta):
	if player == null:
		velocity = Vector2.ZERO
		$sprite.stop() 
		return


	var distance = global_position.distance_to(player.global_position)

	if distance > FOLLOW_DISTANCE:
		var direction = global_position.direction_to(player.global_position)
		velocity = direction * SPEED
		
		if direction.x != 0:
			$sprite.flip_h = direction.x < 0
		
		if not $sprite.is_playing():
			$sprite.play("run")
	else:
		velocity = Vector2.ZERO
		$sprite.stop() 

	move_and_slide()
