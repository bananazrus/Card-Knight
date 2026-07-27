extends Node2D

var speed = 1250
func _ready():
	$Area2D/AnimatedSprite2D.play("fall")

func _physics_process(delta):
	position.y += speed * delta

func _on_handslam_body_entered(body: Node2D) -> void:
	$Area2D/AnimatedSprite2D.play("impact")
	var player = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		player.take_damage(20*Globals.damage_reduction)
	set_physics_process(false)
	await get_tree().create_timer(0.6).timeout
	queue_free()
 
