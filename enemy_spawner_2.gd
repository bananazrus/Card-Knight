extends Node2D
@export var enemy: PackedScene
var enemy_pos =[Vector2(1838,594),Vector2(6308,-621),Vector2(7654,-1080),Vector2(7864,577),Vector2(6026,577),Vector2(5786,577),Vector2(5468,577),Vector2(6026,577),Vector2(5159,577),Vector2(8836,577),]
func _ready() -> void:
	for i in enemy_pos:
		spawn_enemy(i)

func spawn_enemy(enemy_position: Vector2):
	var new_enemy = enemy.instantiate()
	new_enemy.global_position = enemy_position
	add_child(new_enemy)
