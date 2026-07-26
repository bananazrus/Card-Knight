extends RigidBody2D

func launch(initial_velocity: Vector2):
	linear_velocity = initial_velocity
	rotation = linear_velocity.angle()

func _physics_process(_delta):
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()

func _on_arrow_2d_body_entered(_body: Node2D) -> void:
	queue_free()
