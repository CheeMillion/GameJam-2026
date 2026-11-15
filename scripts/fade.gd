extends CanvasLayer

var rect: ColorRect

func _ready() -> void:
	layer = 100
	rect = ColorRect.new()
	rect.color = Color.BLACK
	rect.modulate.a = 0.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(rect)

func fade_out(duration := 0.3) -> void:
	SFX.play("door")
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 1.0, duration)
	await t.finished

func fade_in(duration := 0.3) -> void:
	var t := create_tween()
	t.tween_property(rect, "modulate:a", 0.0, duration)
	await t.finished

func play_intro(duration := 3.0) -> void:
	rect.modulate.a = 1.0
	await fade_in(duration)

func travel(move_callable: Callable, duration := 0.3) -> void:
	await fade_out(duration)
	move_callable.call()
	await fade_in(duration)
