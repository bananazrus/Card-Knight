extends CharacterBody2D


const SPEED = 1300.0
var direction = 0
func _physics_process(delta: float) -> void:
	$Node2D.scale.x=direction
	$Node2D/Sprite2D.show()
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta*3
	if direction:
		velocity.x = direction * SPEED * delta
	if is_on_wall():
		queue_free()
	move_and_slide()


func _on_wave_body_entered(body: Node2D) -> void:
	var player = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		player.take_damage(30*Globals.damage_reduction)
