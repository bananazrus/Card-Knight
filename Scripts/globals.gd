extends Node
var bow : bool = false
var sword : bool = false
var arrow : bool = false
var deck = ["AH","2D","3H","4S","5C","6D","7H","8S","9C","10D","QS","KC","JS","JH"]
var all_cards=["AH","2D","3H","4S","5C","6D","7H","8S","9C","10D","QS","KC","JS","JH"]
var card_pool = ["2C","2H","2S","3C","3D","3S","4C","4D","4H","5D","5H","5S","6C","6H","6S","7C","7D","7S","8C","8D","8H","9D","9H","9S","10C","10S","10H"]
var phase_card_pool = []
var hand=[]
var random_index=0
var damage_buff_5 = 1.0
var seven: bool = false
var discard="empty"
var damage_reduction = 1.0
var sword_increase = 1
var bow_increase = 1
var card_increase = 1
var queen_buff = 1
func _ready() -> void:
	reset_game_state()
func reset_game_state():
	queen_buff = 1
	sword_increase = 1
	bow_increase = 1
	card_increase = 1
	damage_buff_5 = 1
	damage_reduction = 1
	deck = all_cards.duplicate()
	hand = []
	discard = "empty"
	deck.shuffle()
	for i in range(5):
		if deck.size() > 0:
			hand.append(deck.pop_back())
