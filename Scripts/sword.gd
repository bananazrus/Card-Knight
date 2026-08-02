extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var player: CharacterBody2D
func _ready() -> void:
	pass



var is_attacking: bool = false

func _process(_delta: float) -> void:
	set_deferred("monitoring", is_attacking)
	set_deferred("monitorable", is_attacking)
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("SwordAttack") and not is_attacking:
		Attack()
func Attack() -> void:
	is_attacking = true
	animation_player.play("SwordAttack1")
	await animation_player.animation_finished
	is_attacking = false
