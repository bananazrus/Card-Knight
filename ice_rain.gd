extends Area2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hitbox.disabled = true
	animated_sprite.frame = 0
	animated_sprite.play("lightning_strike")

func _on_lightning_frame_changed() -> void:
	if animated_sprite.frame == 2:
		hitbox.disabled = false


func _on_lightning_animation_finished() -> void:
	queue_free()
