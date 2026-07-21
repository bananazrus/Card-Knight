extends Node
var bow : bool = false
var sword : bool = false
var arrow : bool = false
var deck = ["AC","2D","3H","4S","5C","6D","7H","8S","9C","10D"]
var all_cards=["AC","2D","3H","4S","5C","6D","7H","8S","9C","10D"]
var hand=[]
var random_index=0
var discard="empty"
func _ready() -> void:
	reset_game_state()
func reset_game_state():
	deck = all_cards.duplicate()
	hand = []
	discard = "empty"
	deck.shuffle()
	for i in range(5):
		if deck.size() > 0:
			hand.append(deck.pop_back())
