extends Node2D
@export var ranged_enemy: PackedScene
var ranged_enemy_pos = [Vector2(1759,-174),Vector2(4682,-174),Vector2(6030,145)]

#Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in ranged_enemy_pos:
		spawn_ranged_enemy(i)


func spawn_ranged_enemy(ranged_enemy_position: Vector2):
	var new_ranged_enemy = ranged_enemy.instantiate()
	new_ranged_enemy.position = ranged_enemy_position
	add_child(new_ranged_enemy)
