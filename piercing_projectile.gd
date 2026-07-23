extends Area2D

func _physics_process(delta):
	position += transform.x * 2000 * delta

func _on_pierceproj_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Enemies"):
		queue_free()
