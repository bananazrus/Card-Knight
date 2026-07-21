extends AnimatedSprite2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Globals.hand.size()>=1:
		animation=Globals.hand[0]
	else:
		animation="empty"
