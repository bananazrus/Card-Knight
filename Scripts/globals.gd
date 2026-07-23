extends Node
var bow : bool = false
var sword : bool = false
var arrow : bool = false
var deck = ["AC","2D","3H","4S","5C","6D","7H","8S","9C","10D"]
var all_cards=["AC","2D","3H","4S","5C","6D","7H","8S","9C","10D"]
var hand=[]
var random_index=0
var damage_buff_5: = 1
var seven: bool = false
var discard="empty"
var damage_reduction = 1
var sword_increase = 1
var bow_increase = 1
var card_increase = 1
func _ready() -> void:
	reset_game_state()
func reset_game_state():
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
