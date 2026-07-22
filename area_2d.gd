extends Area2D

var speed = 1050
func _physics_process(delta):
	position.y += speed * delta

func _on_projectile_body_entered(body: Node2D) -> void:
	queue_free()
 
