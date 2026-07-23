extends Area2D


func _physics_process(delta):
	position += transform.x * 1000 * delta

func _on_elementalprojectile_body_entered(_body: Node2D) -> void:
	queue_free()
