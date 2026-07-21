extends Node2D
@export var ranged_enemy: PackedScene
var ranged_enemy_pos = [Vector2(6300, -3570), Vector2(6960, -3695), Vector2(9300, -3695),Vector2(1194, -2420), Vector2(535, -2420), Vector2(837, -1650), Vector2(1536, -1650), Vector2(1124, 273)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in ranged_enemy_pos:
		spawn_ranged_enemy(i)


func spawn_ranged_enemy(ranged_enemy_position: Vector2):
	var new_ranged_enemy = ranged_enemy.instantiate()
	new_ranged_enemy.position = ranged_enemy_position
	add_child(new_ranged_enemy)
