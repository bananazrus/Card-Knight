extends Area2D

var speed = 850
func _physics_process(delta):
	position += transform.x * speed * delta

func _on_projectile_body_entered(body: Node2D) -> void:
	var player = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		player.take_damage(10)
	queue_free()
 
