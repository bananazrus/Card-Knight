extends Node2D
@export var enemy: PackedScene
var enemy_pos = [Vector2(-1200,-1100), Vector2(500,-3533), Vector2(500, -5300), Vector2(3100,-5820), Vector2(-3100,-3750), Vector2(-2800, -3750)]

func _ready() -> void:
	for i in enemy_pos:
		spawn_enemy(i)

func spawn_enemy(enemy_position: Vector2):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = enemy_position
	add_child(new_enemy)
