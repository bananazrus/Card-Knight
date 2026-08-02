extends StaticBody2D
var show_door1 = false
var show_door2 = false

# Called when the node enters the scene tree for the first time.
func _process(_delta: float) -> void:
	if show_door1:
		$CollisionShape2D.set_deferred("disabled", false)
	if show_door2 and has_node("CollisionShape2D3"):
		$CollisionShape2D3.set_deferred("disabled", false)
		$CollisionShape2D4.set_deferred("disabled", false)


func _on_node_2d_spawn_door_1() -> void:
	show_door1 = true


func _on_node_2d_spawn_door_2() -> void:
	show_door2 = true
