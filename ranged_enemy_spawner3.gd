extends Node2D
@export var ranged_enemy: PackedScene
var ranged_enemy_pos = [Vector2(2740,-4078), Vector2(-5125,-2478), Vector2(-5421,-2478), Vector2(-7362,-6574), Vector2(-6336,-9966), Vector2(-9920,-6382)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in ranged_enemy_pos:
		spawn_ranged_enemy(i)


func spawn_ranged_enemy(ranged_enemy_position: Vector2):
	var new_ranged_enemy = ranged_enemy.instantiate()
	new_ranged_enemy.position = ranged_enemy_position
	add_child(new_ranged_enemy)
