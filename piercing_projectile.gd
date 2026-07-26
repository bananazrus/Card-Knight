extends Node2D
@onready var animated_sprite: AnimatedSprite2D = $Area2D/Sprite2D
var current_animation: String = "burn"
func _ready() -> void:
	if animated_sprite and current_animation != "":
		animated_sprite.play(current_animation)
func _physics_process(delta):
	position += transform.x * 1000 * delta

func _on_elementalprojectile_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Enemies"):
		queue_free()
func setup(anim_name: String) -> void:
	current_animation = anim_name
	if is_node_ready() and animated_sprite:
		animated_sprite.play(current_animation)
