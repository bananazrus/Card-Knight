extends Label

func display_obtained_card(card: String) -> void:
	var suit_char = card[-1]
	var rank_str = card.left(-1)
	var suit_names = {
		"C": "CLUBS",
		"D": "DIAMONDS",
		"H": "HEARTS",
		"S": "SPADES"
	}
	var suit_name = suit_names.get(suit_char, "")
	text = "CARD OBTAINED:\n%s OF %s" % [rank_str, suit_name]
	show()
	await get_tree().create_timer(3.0).timeout
	hide()
