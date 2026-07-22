extends AnimatedSprite2D
@onready var label: Label = $Label 
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Globals.hand.size()>=1:
		animation=Globals.hand[0]
	else:
		animation="empty"
	

func _on_area_2d_mouse_entered() -> void:
	label.show()


func _on_area_2d_mouse_exited() -> void:
	pass # Replace with function body.
