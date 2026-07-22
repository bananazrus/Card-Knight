extends AnimatedSprite2D
@onready var label: Label = $Label 
var all_cards=[["AC","Summons a bolt of lightning above foes.\n\nType: Lighting"],["2D","Creates an area around the player that deals damage and applies slow.\n\nType: Ice"],["3H","Gives the player bonus health.\n\nType: Buff"],["4S","Shoots a steel projectile that applies bleed.\n\n:Type: Steel"],["5C","Increases damage dealt.\n\nType: Buff"],["6D","Creates a wall around the player.\n\n Type: Buff"],["7H","The next card you play is not discarded.\n\nType: Buff"],["8S","Fires a projectile that bounces from enemy to enemy.\n\nType: Steel"],["9C","Gives significant damage reduction.\n\nType:buff"],["10D","Create a downwards slash of air.\n\nType: Ice"]]
func _process(_delta: float) -> void:
	if Globals.hand.size()>=3:
		animation=Globals.hand[2]
		for i in all_cards:
			if i[0]==Globals.hand[2]:
				label.text=i[1]
	else:
		animation="empty"
func _on_area_2d_mouse_entered() -> void:
	label.show()


func _on_area_2d_mouse_exited() -> void:
	label.hide()
