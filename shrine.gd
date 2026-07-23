extends Area2D
var is_active = true

func _process(_delta: float) -> void:
	if is_active == false:
		$AnimatedSprite2D.play("shrine_off")
	elif is_active:
		$AnimatedSprite2D.play("shrine_on")
