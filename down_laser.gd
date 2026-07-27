extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D2/AnimatedSprite2D.play("fire")


func _on_animated_sprite_2d_animation_finished() -> void:
	$Area2D2/CollisionShape2D.disabled=false
	await get_tree().create_timer(2).timeout
	queue_free()
