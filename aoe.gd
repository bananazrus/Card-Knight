extends Area2D

func _ready() -> void:
	monitoring = true
	$Sprite2D.scale = Vector2(0.01, 0.01)
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(0.385, 0.385), 0.67)
	await tween.finished

	detonate()

func detonate() -> void:
	await get_tree().physics_frame
	for body in get_overlapping_bodies():
		var player = body if body.is_in_group("player") else body.get_parent()
		if player and player.is_in_group("player"):
			if player.has_method("take_damage"):
				player.take_damage(35*Globals.damage_reduction)
	await get_tree().create_timer(0.5).timeout
	queue_free()
