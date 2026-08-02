extends Area2D

var speed = 850
func _physics_process(delta):
	position += transform.x * 1000 * delta

func _on_stun_projectile_body_entered(body: Node2D) -> void:
	var player = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		player.take_damage(10*Globals.damage_reduction)
		player.apply_stun(3.0)
	queue_free()
