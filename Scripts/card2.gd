extends AnimatedSprite2D

@onready var label: Label = $Label 

# Use a Dictionary for fast lookups and clean data structure
const CARD_DESCRIPTIONS: Dictionary = {
	"AC": "Summons a bolt of lightning above foes.",
	"AD": "Summons a cloud of ice rain that deals damage and then explodes.",
	"AH": "Shoots a large beam of fire.",
	"AS": "Shoots a piercing projectile that applies bleed.",
	"JC": "Stuns all enemies nearby.",
	"JD": "The next sword attack is a slash that deals massive damage.",
	"JH": "Summons a projectile that explodes on hit.",
	"JS": "Plays all cards in your hand instantly.",
	"QC": "Releases a burst of lightning around the player.",
	"QD": "Summons ice spikes at enemy positions which deals damage and applies slow.",
	"QH": "Heals the player back to full and gives overshield.",
	"QS": "Increases basic attack damage by 200% for 5 seconds.",
	"KC": "Drastically shortens dash cooldown and causes dash to hurt enemies for 30 seconds.",
	"KD": "Fires a wave of frost that applies slow to all enemies.",
	"KH": "Summons fire on the floor that deals damage and applies burn.",
	"KS": "All attacks deal bleed damage and bleed damage is doubled.",
	"2D": "Creates an area around the player that deals damage and applies slow.",
	"2C": "Creates an area around the player that deals damage and applies shock.",
	"2H": "Creates an area around the player that deals damage and applies burn.",
	"2S": "Creates an area around the player that deals damage and applies bleed.",
	"3H": "Gives the player bonus health.",
	"3C": "Gives the player bonus health.",
	"3S": "Gives the player bonus health.",
	"3D": "Gives the player bonus health.",
	"4S": "Shoots a projectile that applies bleed.",
	"4C": "Shoots a projectile that applies shock.",
	"4D": "Shoots a projectile that applies slow.",
	"4H": "Shoots a projectile that applies burn.",
	"5C": "75% increased damage dealt for 5 seconds.",
	"5D": "75% increased damage dealt for 5 seconds.",
	"5H": "75% increased damage dealt for 5 seconds.",
	"5S": "75% increased damage dealt for 5 seconds.",
	"6D": "Creates a wall around the player that lasts 7 seconds.",
	"6C": "Creates a wall around the player that lasts 7 seconds.",
	"6H": "Creates a wall around the player that lasts 7 seconds.",
	"6S": "Creates a wall around the player that lasts 7 seconds.",
	"7H": "The next card you play is not discarded.",
	"7C": "The next card you play is not discarded.",
	"7D": "The next card you play is not discarded.",
	"7S": "The next card you play is not discarded.",
	"8S": "Fires a projectile that pierces enemies and applies bleed.",
	"8H": "Fires a projectile that pierces enemies and applies burn.",
	"8D": "Fires a projectile that pierces enemies and applies slow.",
	"8C": "Fires a projectile that pierces enemies and applies shock.",
	"9C": "Gives 90% damage reduction for 4 second.",
	"9D": "Gives 90% damage reduction for 4 seconds.",
	"9H": "Gives 90% damage reduction for 4 seconds.",
	"9S": "Gives 90% damage reduction for 4 seconds.",
	"10D": "Create a downwards slash of air.",
	"10C": "Create a downwards slash of air.",
	"10H": "Create a downwards slash of air.",
	"10S": "Create a downwards slash of air."
}

var _last_card: String = "UNSET"
func _ready() -> void:
	_update_card_display(Globals.hand[1])
func _process(_delta: float) -> void:
	var current_card: String = Globals.hand[1]
	if current_card != _last_card:
		_last_card = current_card
		_update_card_display(current_card)

func _update_card_display(card_id: String) -> void:
	animation = card_id
	if card_id != "empty":
		label.text = CARD_DESCRIPTIONS.get(card_id, "Description missing.")
	else:
		label.text = ""

func _on_area_2d_mouse_entered() -> void:
	if not animation == "empty":
		label.show()
		$Sprite2D.hide()

func _on_area_2d_mouse_exited() -> void:
	label.hide()
	$Sprite2D.show()
