extends Node2D
@export var enemy: PackedScene
var enemy_pos = [Vector2(5885, -3500), Vector2(5450, -3500), Vector2(3457, -3500), Vector2(773, -3892), Vector2(3991, -1867), Vector2(558, -559), Vector2(4033, -550)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in enemy_pos:
		spawn_enemy(i)

func spawn_enemy(enemy_position: Vector2):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = enemy_position
	add_child(new_enemy)
