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
	if rank_str=="A":
		text = "CARD OBTAINED:\n ACE OF "+suit_name
	elif rank_str=="K":
		text = "CARD OBTAINED:\n KING OF "+suit_name
	elif rank_str=="Q":
		text = "CARD OBTAINED:\n QUEEN OF "+suit_name
	elif rank_str=="J":
		text = "CARD OBTAINED:\n JACK OF "+suit_name
	else:
		text = "CARD OBTAINED:\n "+ rank_str + " OF "+suit_name
	show()
	await get_tree().create_timer(3.0).timeout
	hide()
