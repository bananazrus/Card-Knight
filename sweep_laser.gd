extends Node2D

var is_facing_left: bool = false

# 60° to -60° is a 120° total arc
var sweep_arc: float = 120.0
var degrees_rotated: float = 0.0
var rotation_speed: float = 60.0
var acceleration: float = 10.0
var can_move = false

func _ready() -> void:
	if is_facing_left:
		# Firing Left: Starts at Down-Right (-60°)
		rotation_degrees = -60.0
	else:
		# Firing Right: Starts at Down-Left (+60°)
		rotation_degrees = 60.0
	
	await get_tree().create_timer(0.6).timeout
	can_move = true

func _process(delta: float) -> void:
	if can_move:
		rotation_speed += acceleration * delta
		var step = rotation_speed * delta
		degrees_rotated += step

		if is_facing_left:
			# Clockwise (+): Sweeps -60° -> 0° (Straight Down) -> +60° (Down-Left)
			rotation_degrees += step
		else:
			# Counter-Clockwise (-): Sweeps +60° -> 0° (Straight Down) -> -60° (Down-Right)
			rotation_degrees -= step

		# Destroy when the 120° arc finishes
		if degrees_rotated >= sweep_arc:
			queue_free()

func _on_laser_2d_body_entered(body: Node2D) -> void:
	var player_node = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		if player_node.has_method("take_damage"):
			player_node.take_damage(40 * Globals.damage_reduction)
