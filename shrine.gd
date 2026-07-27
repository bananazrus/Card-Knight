extends Area2D

var is_active = true

func _ready() -> void:
	add_to_group("shrine")

func _process(_delta: float) -> void:
	if not is_active:
		$AnimatedSprite2D.play("shrine_off")
	else:
		$AnimatedSprite2D.play("shrine_on")
