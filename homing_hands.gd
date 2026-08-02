extends Area2D

@export var speed: float = 800.0
@export var turn_speed: float = 1
@export var lifetime: float = 5.0

var target: Node2D = null

func _ready() -> void:
	target = get_tree().get_first_node_in_group("player")
	get_tree().create_timer(lifetime).timeout.connect(queue_free)

func _physics_process(delta: float) -> void:
	if is_instance_valid(target):
		var target_angle: float = (target.global_position - global_position).angle()
		rotation = rotate_toward(rotation, target_angle, turn_speed * delta)
	position += Vector2.RIGHT.rotated(rotation) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	var player = body if body.is_in_group("player") else body.get_parent()
	if body.is_in_group("player") or body.get_parent().is_in_group("player"):
		player.take_damage(20*Globals.damage_reduction)
		queue_free()
