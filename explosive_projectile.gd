extends Node2D

@onready var animated_sprite: AnimatedSprite2D = $Area2D/AnimatedSprite2D
@onready var projectile_collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var explosion_collision: CollisionShape2D = $Area2D/CollisionShape2D2

# Prevents the signal from running twice when the explosion shape hits something
var is_exploding: bool = false

func _ready() -> void:
	# Ensure the explosion shape is disabled at the start
	animated_sprite.play("shoot")
	explosion_collision.disabled = true

func _physics_process(delta: float) -> void:
	position += transform.x * 1000 * delta

func _on_explosive_projectile_body_entered(_body: Node2D) -> void:
	# Ignore future collisions while already exploding
	if is_exploding:
		return
	is_exploding = true

	# 1. Stop movement
	set_physics_process(false)

	# 2. Swap collision shapes safely
	projectile_collision.set_deferred("disabled", true)
	explosion_collision.set_deferred("disabled", false)

	# 3. Play animation and wait for completion
	animated_sprite.play("explode")
	await animated_sprite.animation_finished
	queue_free()
