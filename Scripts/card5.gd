extends AnimatedSprite2D

@onready var label: Label = $Label 

# Use a Dictionary for fast lookups and clean data structure
const CARD_DESCRIPTIONS: Dictionary = {
	"AC": "Summons a bolt of lightning above foes.\n\nType: Lightning",
	"AD": "Summons a cloud of ice rain that deals damage and then explodes.\n\nType: Ice",
	"AH": "Shoots a large beam of fire.\n\nType: Fire",
	"AS": "Shoots a piercing projectile that applies bleed.\n\nType: Steel",
	"JC": "Stuns all enemies nearby.\n\nType: Debuff",
	"JD": "The next sword attack is a slash that deals massive damage.\n\nType: Ice",
	"JH": "Summons a projectile that explodes on hit.\n\nType: Fire",
	"JS": "Plays all cards in your hand instantly.\n\nType: Buff",
	"QC": "Releases a burst of lightning around the player.\n\nType: Lightning",
	"QD": "Summons ice spikes at enemy positions which deals damage and applies slow.\n\nType: Ice",
	"QH": "Heals the player back to full and gives overshield.\n\nType: Buff",
	"QS": "Increases basic attack damage by 200% for 5 seconds.\n\nType: Buff",
	"KC": "Drastically shortens dash cooldown and causes dash to hurt enemies for 30 seconds.\n\nType: Buff",
	"KD": "Fires a wave of frost that applies slow to all enemies.\n\nType: Ice",
	"KH": "Summons fire on the floor that deals damage and applies burn.\n\nType: Fire",
	"KS": "All attacks deal bleed damage and bleed damage is doubled..\n\nType: Buff",
	"2D": "Creates an area around the player that deals damage and applies slow.\n\nType: Ice",
	"2C": "Creates an area around the player that deals damage and applies shock.\n\nType: Lightning",
	"2H": "Creates an area around the player that deals damage and applies burn.\n\nType: Fire",
	"2S": "Creates an area around the player that deals damage and applies bleed.\n\nType: Steel", # Fixed key from 2D to 2S
	"3H": "Gives the player bonus health.\n\nType: Buff",
	"3C": "Gives the player bonus health.\n\nType: Buff",
	"3S": "Gives the player bonus health.\n\nType: Buff",
	"3D": "Gives the player bonus health.\n\nType: Buff",
	"4S": "Shoots a projectile that applies bleed.\n\nType: Steel",
	"4C": "Shoots a projectile that applies shock.\n\nType: Lightning",
	"4D": "Shoots a projectile that applies slow.\n\nType: Ice",
	"4H": "Shoots a projectile that applies burn.\n\nType: Fire",
	"5C": "75% increased damage dealt for 5 seconds.\n\nType: Buff",
	"5D": "75% increased damage dealt for 5 seconds.\n\nType: Buff",
	"5H": "75% increased damage dealt for 5 seconds.\n\nType: Buff",
	"5S": "75% increased damage dealt for 5 seconds.\n\nType: Buff",
	"6D": "Creates a wall around the player that lasts 7 seconds.\n\nType: Buff",
	"6C": "Creates a wall around the player that lasts 7 seconds.\n\nType: Buff",
	"6H": "Creates a wall around the player that lasts 7 seconds.\n\nType: Buff",
	"6S": "Creates a wall around the player that lasts 7 seconds.\n\nType: Buff",
	"7H": "The next card you play is not discarded.\n\nType: Buff",
	"7C": "The next card you play is not discarded.\n\nType: Buff",
	"7D": "The next card you play is not discarded.\n\nType: Buff",
	"7S": "The next card you play is not discarded.\n\nType: Buff",
	"8S": "Fires a projectile that pierces enemies and applies bleed.\n\nType: Steel",
	"8H": "Fires a projectile that pierces enemies and applies burn.\n\nType: Fire",
	"8D": "Fires a projectile that pierces enemies and applies slow.\n\nType: Ice",
	"8C": "Fires a projectile that pierces enemies and applies shock.\n\nType: Lightning",
	"9C": "Gives 90% damage reduction for 4 second.\n\nType: Buff",
	"9D": "Gives 90% damage reduction for 4 seconds.\n\nType: Buff",
	"9H": "Gives 90% damage reduction for 4 seconds.\n\nType: Buff",
	"9S": "Gives 90% damage reduction for 4 seconds.\n\nType: Buff",
	"10D": "Create a downwards slash of air.",
	"10C": "Create a downwards slash of air.",
	"10H": "Create a downwards slash of air.",
	"10S": "Create a downwards slash of air."
}

var _last_card: String = "UNSET"
func _ready() -> void:
	if Globals.hand.size() > 4:
		_update_card_display(Globals.hand[4])
func _process(_delta: float) -> void:
	var current_card: String = Globals.hand[4] if Globals.hand.size() > 4 else ""
	
	# Only update graphics/label when the top card changes
	if current_card != _last_card:
		_last_card = current_card
		_update_card_display(current_card)

func _update_card_display(card_id: String) -> void:
	if card_id != "":
		animation = card_id
		label.text = CARD_DESCRIPTIONS.get(card_id, "Description missing.")
	else:
		animation = "empty"
		label.text = ""

func _on_area_2d_mouse_entered() -> void:
	if not animation == "empty":
		label.show()

func _on_area_2d_mouse_exited() -> void:
	label.hide()
