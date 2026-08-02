extends RigidBody2D
@onready var arrow_hit: AudioStreamPlayer2D = $AudioStreamPlayer2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
func launch(initial_velocity: Vector2):
	linear_velocity = initial_velocity
	rotation = linear_velocity.angle()

func _physics_process(_delta):
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()

func _on_arrow_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemies"):
		sprite_2d.visible = false
		collision_shape_2d.set_deferred("disabled", true)
		linear_velocity = Vector2.ZERO
		arrow_hit.play()
		await arrow_hit.finished
	queue_free()
