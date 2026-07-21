extends RigidBody2D

func shoot(mouse_pos,start_pos):
	visible = false
	await get_tree().create_timer(0.1).timeout
	linear_velocity = (mouse_pos - start_pos).normalized() * 1500
	rotation = linear_velocity.angle()
	visible = true

func _physics_process(_delta):
	if linear_velocity.length() > 0:
		rotation = linear_velocity.angle()

func _on_arrow_2d_body_entered(_body: Node2D) -> void:
	queue_free()
