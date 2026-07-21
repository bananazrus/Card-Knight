extends Node
var bow : bool = false
var sword : bool = false
var arrow : bool = false
var deck = ["AC","2D","3H","4S","5C","6D","7H","8S","9C","10D"]
var hand=[]
var random_index=0
var discard="empty"
func _ready() -> void:
	deck.shuffle()
	while hand.size()!=5:
		random_index=randi_range(0, deck.size()-1)
		hand.append(deck[random_index])
		deck.remove_at(random_index)			
