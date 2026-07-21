extends AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Globals.hand.size()>=3:
		animation=Globals.hand[2]
	else:
		animation="empty"
