extends Node2D
@export var enemy: PackedScene
var enemy_pos = [Vector2(3000,-3700), Vector2(1200,90), Vector2(-2780,-2650), Vector2(-1300, -2650), Vector2(-10300, -4000), Vector2(-8800,-6116), Vector2(-9900, -6000)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in enemy_pos:
		spawn_enemy(i)

func spawn_enemy(enemy_position: Vector2):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = enemy_position
	add_child(new_enemy)
